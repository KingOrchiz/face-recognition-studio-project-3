cmake_minimum_required(VERSION 3.16)
project(FaceRecognitionStudio VERSION 0.1.0 LANGUAGES CXX)

option(FACE_STUDIO_WARNINGS_AS_ERRORS
    "Treat Face Recognition Studio compiler warnings as errors" OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(OpenCV 4.5 REQUIRED COMPONENTS core imgproc imgcodecs videoio highgui objdetect dnn)

# YuNet's ONNX graph compatibility differs across OpenCV 4 releases.
if(OpenCV_VERSION VERSION_GREATER_EQUAL "4.10")
    set(FACE_STUDIO_YUNET_MODEL face_detection_yunet_2023mar.onnx)
else()
    set(FACE_STUDIO_YUNET_MODEL face_detection_yunet_2022mar.onnx)
endif()

add_executable(face_studio
    src/main.cpp
    include/FrameSource.hpp
    include/Logger.hpp)
target_include_directories(face_studio PRIVATE include)
target_link_libraries(face_studio PRIVATE ${OpenCV_LIBS})
target_compile_options(face_studio PRIVATE -Wall -Wextra -Wpedantic)
if(FACE_STUDIO_WARNINGS_AS_ERRORS)
    target_compile_options(face_studio PRIVATE -Werror)
endif()
target_compile_definitions(face_studio PRIVATE
    FACE_STUDIO_VERSION="${PROJECT_VERSION}"
    FACE_STUDIO_DEFAULT_DETECTOR="${FACE_STUDIO_YUNET_MODEL}")

enable_testing()
add_test(NAME help COMMAND face_studio --help)
add_test(NAME version COMMAND face_studio --version)
add_test(
    NAME image_smoke
    COMMAND face_studio
        --mode image
        --input ${CMAKE_CURRENT_SOURCE_DIR}/tests/synthetic_portrait_a.png
        --detector ${CMAKE_CURRENT_SOURCE_DIR}/models/face_detection_yunet_2023mar.onnx
        --recognizer ${CMAKE_CURRENT_SOURCE_DIR}/models/face_recognition_sface_2021dec.onnx
        --known ${CMAKE_CURRENT_SOURCE_DIR}/data/known
        --overwrite
        --output ${CMAKE_CURRENT_BINARY_DIR}/ctest-output/synthetic_portrait_a.png)
set_tests_properties(image_smoke PROPERTIES PASS_REGULAR_EXPRESSION "Detected 1 face\\(s\\)")

add_test(NAME invalid_mode COMMAND face_studio --mode invalid)
set_tests_properties(invalid_mode PROPERTIES WILL_FAIL TRUE)

add_test(NAME camera_consent_gate COMMAND face_studio --mode camera)
set_tests_properties(camera_consent_gate PROPERTIES WILL_FAIL TRUE)

add_test(NAME invalid_threshold COMMAND face_studio --mode image --input ignored --threshold 1.1)
set_tests_properties(invalid_threshold PROPERTIES WILL_FAIL TRUE)

add_test(
    NAME recognition_known
    COMMAND face_studio
        --mode image
        --input ${CMAKE_CURRENT_SOURCE_DIR}/tests/synthetic_portrait_a_variant_640.png
        --detector ${CMAKE_CURRENT_SOURCE_DIR}/models/${FACE_STUDIO_YUNET_MODEL}
        --recognizer ${CMAKE_CURRENT_SOURCE_DIR}/models/face_recognition_sface_2021dec.onnx
        --known ${CMAKE_CURRENT_SOURCE_DIR}/tests/known
        --threshold 0.400
        --overwrite
        --output ${CMAKE_CURRENT_BINARY_DIR}/ctest-output/recognition-known.png)
set_tests_properties(recognition_known PROPERTIES PASS_REGULAR_EXPRESSION "label=Synthetic_A")

add_test(
    NAME recognition_unknown
    COMMAND face_studio
        --mode image
        --input ${CMAKE_CURRENT_SOURCE_DIR}/tests/synthetic_portrait_b_unknown_640.png
        --detector ${CMAKE_CURRENT_SOURCE_DIR}/models/${FACE_STUDIO_YUNET_MODEL}
        --recognizer ${CMAKE_CURRENT_SOURCE_DIR}/models/face_recognition_sface_2021dec.onnx
        --known ${CMAKE_CURRENT_SOURCE_DIR}/tests/known
        --threshold 0.400
        --overwrite
        --output ${CMAKE_CURRENT_BINARY_DIR}/ctest-output/recognition-unknown.png)
set_tests_properties(recognition_unknown PROPERTIES PASS_REGULAR_EXPRESSION "label=Unknown")

add_test(
    NAME video_smoke
    COMMAND face_studio
        --mode video
        --input ${CMAKE_CURRENT_SOURCE_DIR}/tests/synthetic_portrait_a_3s.mp4
        --detector ${CMAKE_CURRENT_SOURCE_DIR}/models/${FACE_STUDIO_YUNET_MODEL}
        --recognizer ${CMAKE_CURRENT_SOURCE_DIR}/models/face_recognition_sface_2021dec.onnx
        --known ${CMAKE_CURRENT_SOURCE_DIR}/tests/known
        --threshold 0.400
        --overwrite)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/ctest-default-video)
set_tests_properties(video_smoke PROPERTIES
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/ctest-default-video
    PASS_REGULAR_EXPRESSION "Processed 30 frame\\(s\\); wrote output/result.mp4")
