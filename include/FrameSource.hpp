#pragma once

#include <opencv2/imgcodecs.hpp>
#include <opencv2/videoio.hpp>

#include <stdexcept>
#include <string>

class IFrameSource {
public:
    virtual ~IFrameSource() = default;
    virtual bool read(cv::Mat& frame) = 0;
    virtual int width() const = 0;
    virtual int height() const = 0;
    virtual double fps() const = 0;
    virtual bool isStream() const = 0;
};

class ImageSource final : public IFrameSource {
public:
    explicit ImageSource(const std::string& path) : image_(cv::imread(path)) {
        if (image_.empty()) throw std::runtime_error("Cannot read image: " + path);
    }

    bool read(cv::Mat& frame) override {
        if (consumed_) return false;
        frame = image_.clone();
        consumed_ = true;
        return true;
    }
    int width() const override { return image_.cols; }
    int height() const override { return image_.rows; }
    double fps() const override { return 0.0; }
    bool isStream() const override { return false; }

private:
    cv::Mat image_;
    bool consumed_ = false;
};

class VideoSource : public IFrameSource {
public:
    explicit VideoSource(const std::string& path) { open(path); }

    bool read(cv::Mat& frame) override { return capture_.read(frame); }
    int width() const override { return static_cast<int>(capture_.get(cv::CAP_PROP_FRAME_WIDTH)); }
    int height() const override { return static_cast<int>(capture_.get(cv::CAP_PROP_FRAME_HEIGHT)); }
    double fps() const override {
        const double value = capture_.get(cv::CAP_PROP_FPS);
        return value > 0.0 && value <= 240.0 ? value : 25.0;
    }
    bool isStream() const override { return true; }

protected:
    VideoSource() = default;
    void open(const std::string& path) {
        capture_.open(path);
        if (!capture_.isOpened()) throw std::runtime_error("Cannot open video source");
    }
    cv::VideoCapture capture_;
};

class CameraSource final : public IFrameSource {
public:
    explicit CameraSource(int index) {
        capture_.open(index);
        if (!capture_.isOpened()) throw std::runtime_error("Cannot open camera source");
    }
    bool read(cv::Mat& frame) override { return capture_.read(frame); }
    int width() const override { return static_cast<int>(capture_.get(cv::CAP_PROP_FRAME_WIDTH)); }
    int height() const override { return static_cast<int>(capture_.get(cv::CAP_PROP_FRAME_HEIGHT)); }
    double fps() const override {
        const double value = capture_.get(cv::CAP_PROP_FPS);
        return value > 0.0 && value <= 240.0 ? value : 25.0;
    }
    bool isStream() const override { return true; }

private:
    cv::VideoCapture capture_;
};
