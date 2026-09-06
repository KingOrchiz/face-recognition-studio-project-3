#include <opencv2/dnn.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/videoio.hpp>

#include "FrameSource.hpp"
#include "Logger.hpp"

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdint>
#include <filesystem>
#include <iomanip>
#include <iostream>
#include <limits>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace fs = std::filesystem;

#if CV_VERSION_MAJOR > 4 || (CV_VERSION_MAJOR == 4 && CV_VERSION_MINOR >= 10)
constexpr float kYuNetScoreThreshold = 0.6f;
#else
constexpr float kYuNetScoreThreshold = 0.9f;
#endif

#ifndef FACE_STUDIO_VERSION
#define FACE_STUDIO_VERSION "development"
#endif

#ifndef FACE_STUDIO_DEFAULT_DETECTOR
#define FACE_STUDIO_DEFAULT_DETECTOR "face_detection_yunet_2023mar.onnx"
#endif

struct Options {
    std::string mode;
    std::string input;
    std::string detectorModel = "models/" FACE_STUDIO_DEFAULT_DETECTOR;
    std::string recognizerModel = "models/face_recognition_sface_2021dec.onnx";
    std::string cascadeModel;
    std::string knownDir = "data/known";
    std::string output;
    double threshold = 0.400;
    bool display = false;
    bool cameraConfirmed = false;
    bool outputSpecified = false;
    bool overwrite = false;
};

struct Identity {
    std::string name;
    cv::Mat feature;
};

static double parseStrictDouble(const std::string& value, const std::string& option) {
    std::size_t consumed = 0;
    double parsed = 0.0;
    try {
        parsed = std::stod(value, &consumed);
    } catch (const std::exception&) {
        throw std::runtime_error(option + " requires a number: " + value);
    }
    if (consumed != value.size())
        throw std::runtime_error(option + " requires a number without trailing characters: " + value);
    return parsed;
}

static int parseCameraIndex(const std::string& value) {
    std::size_t consumed = 0;
    long long parsed = 0;
    try {
        parsed = std::stoll(value, &consumed);
    } catch (const std::exception&) {
        throw std::runtime_error("--input requires a non-negative camera index: " + value);
    }
    if (consumed != value.size() || parsed < 0
        || parsed > std::numeric_limits<int>::max()) {
        throw std::runtime_error("--input requires a non-negative camera index: " + value);
    }
    return static_cast<int>(parsed);
}

static bool pathsReferToSameFile(const fs::path& first, const fs::path& second) {
    std::error_code ec;
    if (fs::exists(first, ec) && !ec && fs::exists(second, ec) && !ec) {
        const bool equivalent = fs::equivalent(first, second, ec);
        if (!ec) return equivalent;
    }
    ec.clear();
    const fs::path firstResolved = fs::weakly_canonical(fs::absolute(first), ec);
    if (ec) return false;
    const fs::path secondResolved = fs::weakly_canonical(fs::absolute(second), ec);
    return !ec && firstResolved == secondResolved;
}

static bool pathEntryExists(const fs::path& path) {
    std::error_code ec;
    const fs::file_status status = fs::symlink_status(path, ec);
    return !ec && status.type() != fs::file_type::not_found;
}

static void validateReplaceableOutputPath(const fs::path& output,
                                          const std::string& mediaType,
                                          bool overwrite) {
    std::error_code ec;
    const fs::file_status status = fs::symlink_status(output, ec);
    if (status.type() == fs::file_type::not_found
        || ec == std::errc::no_such_file_or_directory) return;
    if (ec)
        throw std::runtime_error(mediaType + " output path could not be inspected safely");
    if (!overwrite)
        throw std::runtime_error(
            mediaType + " output already exists; pass --overwrite to replace it explicitly");
    if (status.type() != fs::file_type::regular)
        throw std::runtime_error(
            mediaType + " --overwrite requires an existing regular file, not a link or directory");

    const std::uintmax_t linkCount = fs::hard_link_count(output, ec);
    if (ec || linkCount != 1)
        throw std::runtime_error(
            mediaType + " --overwrite requires a file with exactly one hard link");
}

static bool hasMp4Extension(const fs::path& output) {
    std::string extension = output.extension().string();
    std::transform(extension.begin(), extension.end(), extension.begin(),
                   [](unsigned char ch) { return static_cast<char>(std::tolower(ch)); });
    return extension == ".mp4";
}

static void validateCameraOutputPath(const fs::path& output) {
    if (output.empty()) return;
    if (!hasMp4Extension(output))
        throw std::runtime_error("Camera output must use an .mp4 filename");
    if (pathEntryExists(output))
        throw std::runtime_error(
            "Camera output already exists; choose an unused path to preserve prior evidence");

    const fs::path parent = output.parent_path().empty() ? fs::path(".") : output.parent_path();
    std::error_code ec;
    const bool parentIsDirectory = fs::is_directory(parent, ec);
    if (ec || !parentIsDirectory)
        throw std::runtime_error(
            "Camera output parent directory must already exist and be a directory");
}

static void usage() {
    std::cout
        << "Face Recognition Studio " FACE_STUDIO_VERSION "\n\n"
        << "Usage:\n"
        << "  face_studio --mode image --input FILE [options]\n"
        << "  face_studio --mode video --input FILE [options]\n"
        << "  face_studio --mode camera [--input INDEX] [options]\n\n"
        << "Options:\n"
        << "  --detector FILE    YuNet ONNX model\n"
        << "  --recognizer FILE  SFace ONNX model\n"
        << "  --cascade FILE     Haar XML fallback (auto-discovered by default)\n"
        << "  --known DIR        labelled images; name is filename stem\n"
        << "  --threshold N      cosine match threshold (default 0.400)\n"
        << "  --output FILE      image/video output path\n"
        << "  --overwrite        allow replacing an existing image/video output\n"
        << "  --display          show a window; press q or Esc to stop\n"
        << "  --confirm-camera   confirm consent before opening camera mode\n"
        << "  --help | --version | --build-info\n";
}

static void buildInfo() {
    std::cout
        << "Face Recognition Studio " FACE_STUDIO_VERSION "\n"
        << "OpenCV " CV_VERSION "\n"
        << "Default detector: models/" FACE_STUDIO_DEFAULT_DETECTOR "\n";
}

static Options parse(int argc, char** argv) {
    Options o;
    for (int i = 1; i < argc; ++i) {
        const std::string a = argv[i];
        auto value = [&]() -> std::string {
            if (++i >= argc) throw std::runtime_error("Missing value after " + a);
            return argv[i];
        };
        if (a == "--help") { usage(); std::exit(0); }
        if (a == "--version") { std::cout << FACE_STUDIO_VERSION "\n"; std::exit(0); }
        if (a == "--build-info") { buildInfo(); std::exit(0); }
        if (a == "--mode") o.mode = value();
        else if (a == "--input") o.input = value();
        else if (a == "--detector") o.detectorModel = value();
        else if (a == "--recognizer") o.recognizerModel = value();
        else if (a == "--cascade") o.cascadeModel = value();
        else if (a == "--known") o.knownDir = value();
        else if (a == "--threshold") o.threshold = parseStrictDouble(value(), "--threshold");
        else if (a == "--output") {
            o.output = value();
            o.outputSpecified = true;
        }
        else if (a == "--display") o.display = true;
        else if (a == "--overwrite") o.overwrite = true;
        else if (a == "--confirm-camera") o.cameraConfirmed = true;
        else throw std::runtime_error("Unknown option: " + a);
    }
    if (o.mode.empty()) throw std::runtime_error("--mode is required");
    if (o.mode != "image" && o.mode != "video" && o.mode != "camera")
        throw std::runtime_error("--mode must be image, video, or camera");
    if (o.mode != "camera" && o.input.empty())
        throw std::runtime_error("--input is required for image and video modes");
    if (!o.outputSpecified)
        o.output = o.mode == "image" ? "output/result.jpg" : "output/result.mp4";
    if (o.mode == "image" && o.output.empty())
        throw std::runtime_error("--output cannot be empty in image mode");
    if (o.mode == "camera" && !o.cameraConfirmed)
        throw std::runtime_error(
            "Camera access blocked: obtain participant consent, then pass --confirm-camera");
    if (o.mode == "camera" && o.overwrite)
        throw std::runtime_error(
            "--overwrite is not allowed in camera mode; choose an unused output path");
    if (o.mode == "camera" && !o.input.empty())
        parseCameraIndex(o.input);
    if ((o.mode == "video" || o.mode == "camera") && o.output.empty() && !o.display)
        throw std::runtime_error(
            "Stream output may be empty only when --display is enabled");
    if (o.mode == "camera") validateCameraOutputPath(o.output);
    if (o.mode == "video" && !o.output.empty() && !hasMp4Extension(o.output))
        throw std::runtime_error("Video output must use an .mp4 filename");
    if ((o.mode == "image" || o.mode == "video") && !o.output.empty()
        && pathsReferToSameFile(o.input, o.output)) {
        const std::string mediaType = o.mode == "image" ? "Image" : "Video";
        throw std::runtime_error(
            mediaType + " output must differ from input; refusing to overwrite the source file");
    }
    if ((o.mode == "image" || o.mode == "video") && !o.output.empty()) {
        const std::string mediaType = o.mode == "image" ? "Image" : "Video";
        validateReplaceableOutputPath(o.output, mediaType, o.overwrite);
    }
    if (!std::isfinite(o.threshold) || o.threshold < -1.0 || o.threshold > 1.0)
        throw std::runtime_error("--threshold must be a finite value from -1 to 1");
    return o;
}

static fs::path findCascade(const std::string& requested) {
    if (!requested.empty()) return requested;
    const std::vector<fs::path> candidates = {
        "/usr/share/opencv4/haarcascades/haarcascade_frontalface_default.xml",
        "/opt/homebrew/share/opencv4/haarcascades/haarcascade_frontalface_default.xml",
        "/usr/local/share/opencv4/haarcascades/haarcascade_frontalface_default.xml",
        "/opt/homebrew/opt/opencv/share/opencv4/haarcascades/haarcascade_frontalface_default.xml",
        "/opt/homebrew/opt/opencv@4/share/opencv4/haarcascades/haarcascade_frontalface_default.xml",
        "/usr/local/opt/opencv/share/opencv4/haarcascades/haarcascade_frontalface_default.xml"
    };
    const auto found = std::find_if(candidates.begin(), candidates.end(), [](const fs::path& p) {
        return fs::exists(p);
    });
    return found == candidates.end() ? fs::path{} : *found;
}

static void createOutputParent(const fs::path& output) {
    const fs::path parent = output.parent_path();
    if (!parent.empty()) fs::create_directories(parent);
}

class FaceEngine {
public:
    explicit FaceEngine(const Options& o)
        : threshold_(o.threshold),
          detector_(cv::FaceDetectorYN::create(o.detectorModel, "", cv::Size(320, 320),
                                               kYuNetScoreThreshold, 0.3f, 5000)),
          recognizer_(cv::FaceRecognizerSF::create(o.recognizerModel, "")) {
        const fs::path cascadePath = findCascade(o.cascadeModel);
        if (!cascadePath.empty() && !cascade_.load(cascadePath.string()))
            throw std::runtime_error("Cannot load Haar fallback: " + cascadePath.string());
    }

    cv::Mat detect(const cv::Mat& frame) {
        try {
            detector_->setInputSize(frame.size());
            cv::Mat faces;
            detector_->detect(frame, faces);
            lastDetectionUsedFallback_ = false;
            return faces;
        } catch (const cv::Exception& e) {
            if (cascade_.empty())
                throw std::runtime_error(std::string("YuNet failed and no Haar cascade was found. ") +
                                         "Provide --cascade FILE. OpenCV error: " + e.what());
            lastDetectionUsedFallback_ = true;
            if (!fallbackReported_) {
                std::cerr << "Warning: YuNet model/runtime mismatch; using Haar detection fallback. "
                          << "Recognition requires a YuNet-compatible OpenCV runtime.\n"
                          << "YuNet detail: " << e.what() << "\n";
                fallbackReported_ = true;
            }
            cv::Mat gray;
            cv::cvtColor(frame, gray, cv::COLOR_BGR2GRAY);
            std::vector<cv::Rect> boxes;
            cascade_.detectMultiScale(gray, boxes, 1.1, 4, 0, cv::Size(30, 30));
            cv::Mat faces = cv::Mat::zeros(static_cast<int>(boxes.size()), 15, CV_32F);
            for (int i = 0; i < faces.rows; ++i) {
                faces.at<float>(i, 0) = static_cast<float>(boxes[i].x);
                faces.at<float>(i, 1) = static_cast<float>(boxes[i].y);
                faces.at<float>(i, 2) = static_cast<float>(boxes[i].width);
                faces.at<float>(i, 3) = static_cast<float>(boxes[i].height);
            }
            return faces;
        }
    }

    cv::Mat feature(const cv::Mat& frame, const cv::Mat& faceRow) {
        cv::Mat aligned, feat;
        recognizer_->alignCrop(frame, faceRow, aligned);
        recognizer_->feature(aligned, feat);
        return feat.clone();
    }

    void loadKnown(const fs::path& dir) {
        if (!fs::exists(dir)) return;
        std::vector<fs::path> files;
        for (const auto& entry : fs::directory_iterator(dir)) {
            if (entry.is_regular_file()) files.push_back(entry.path());
        }
        std::sort(files.begin(), files.end());
        for (const auto& file : files) {
            cv::Mat image = cv::imread(file.string());
            if (image.empty()) continue;
            cv::Mat faces = detect(image);
            if (lastDetectionUsedFallback_) {
                if (!recognitionFallbackReported_) {
                    std::cerr << "Skipping known-reference enrollment because Haar fallback has no "
                              << "five-point landmarks required by SFace.\n";
                    recognitionFallbackReported_ = true;
                }
                continue;
            }
            if (faces.rows != 1) {
                std::cerr << "Skipping " << file << ": expected one face, found " << faces.rows << "\n";
                continue;
            }
            known_.push_back({file.stem().string(), feature(image, faces.row(0))});
        }
        std::cout << "Loaded " << known_.size() << " known identities\n";
    }

    std::pair<std::string, double> identify(const cv::Mat& feat) const {
        std::string bestName = "Unknown";
        double best = -1.0;
        for (const auto& id : known_) {
            const double score = recognizer_->match(feat, id.feature, cv::FaceRecognizerSF::FR_COSINE);
            if (score > best) { best = score; bestName = id.name; }
        }
        if (best < threshold_) bestName = "Unknown";
        return {bestName, best};
    }

    int annotate(cv::Mat& frame, bool reportFaces = false) {
        cv::Mat faces = detect(frame);
        for (int i = 0; i < faces.rows; ++i) {
            const cv::Mat row = faces.row(i);
            const cv::Rect box(
                std::max(0, static_cast<int>(row.at<float>(0, 0))),
                std::max(0, static_cast<int>(row.at<float>(0, 1))),
                std::max(1, static_cast<int>(row.at<float>(0, 2))),
                std::max(1, static_cast<int>(row.at<float>(0, 3))));
            const auto [name, score] = known_.empty() || lastDetectionUsedFallback_
                ? std::make_pair(std::string("Unknown"), -1.0)
                : identify(feature(frame, row));
            cv::rectangle(frame, box, cv::Scalar(40, 210, 80), 2);
            std::string label = name;
            if (score >= 0.0) {
                std::ostringstream ss;
                ss << name << " " << std::fixed << std::setprecision(2) << score;
                label = ss.str();
            }
            if (reportFaces) {
                std::cout << "Face " << (i + 1) << ": label=" << name;
                if (score >= 0.0)
                    std::cout << ", cosine=" << std::fixed << std::setprecision(6) << score
                              << ", threshold=" << threshold_;
                else
                    std::cout << ", cosine=not-computed";
                std::cout << "\n";
            }
            cv::putText(frame, label, cv::Point(box.x, std::max(20, box.y - 8)),
                        cv::FONT_HERSHEY_SIMPLEX, 0.6, cv::Scalar(40, 210, 80), 2);
        }
        cv::putText(frame, "Faces: " + std::to_string(faces.rows), cv::Point(15, 30),
                    cv::FONT_HERSHEY_SIMPLEX, 0.8, cv::Scalar(0, 220, 255), 2);
        return faces.rows;
    }

private:
    double threshold_;
    cv::Ptr<cv::FaceDetectorYN> detector_;
    cv::Ptr<cv::FaceRecognizerSF> recognizer_;
    cv::CascadeClassifier cascade_;
    bool fallbackReported_ = false;
    bool recognitionFallbackReported_ = false;
    bool lastDetectionUsedFallback_ = false;
    std::vector<Identity> known_;
};

static int runImage(const Options& o, FaceEngine& engine) {
    ImageSource source(o.input);
    cv::Mat image;
    source.read(image);
    const int count = engine.annotate(image, true);
    createOutputParent(o.output);
    if (!cv::imwrite(o.output, image)) throw std::runtime_error("Cannot write: " + o.output);
    std::cout << "Detected " << count << " face(s); wrote " << o.output << "\n";
    if (o.display) { cv::imshow("Face Recognition Studio", image); cv::waitKey(0); }
    return 0;
}

static int runStream(const Options& o, FaceEngine& engine) {
    std::unique_ptr<IFrameSource> source;
    if (o.mode == "camera")
        source = std::make_unique<CameraSource>(o.input.empty() ? 0 : parseCameraIndex(o.input));
    else
        source = std::make_unique<VideoSource>(o.input);

    const int width = source->width();
    const int height = source->height();
    const double fps = source->fps();
    cv::VideoWriter writer;
    if (!o.output.empty()) {
        createOutputParent(o.output);
        writer.open(o.output, cv::VideoWriter::fourcc('m','p','4','v'), fps, cv::Size(width, height));
        if (!writer.isOpened()) throw std::runtime_error("Cannot create video: " + o.output);
    }

    cv::Mat frame;
    std::size_t frames = 0;
    while (source->read(frame)) {
        engine.annotate(frame);
        if (writer.isOpened()) writer.write(frame);
        ++frames;
        if (o.display) {
            cv::imshow("Face Recognition Studio", frame);
            const int key = cv::waitKey(1);
            if (key == 27 || key == 'q') break;
        }
    }
    std::cout << "Processed " << frames << " frame(s)";
    if (writer.isOpened()) std::cout << "; wrote " << o.output;
    std::cout << "\n";
    return 0;
}

int main(int argc, char** argv) {
    try {
        const Options options = parse(argc, argv);
        for (const auto& model : {options.detectorModel, options.recognizerModel}) {
            if (!fs::exists(model)) throw std::runtime_error("Model not found: " + model);
        }
        FaceEngine engine(options);
        engine.loadKnown(options.knownDir);
        return options.mode == "image" ? runImage(options, engine) : runStream(options, engine);
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        std::cerr << "Run with --help for usage.\n";
        return 2;
    }
}
