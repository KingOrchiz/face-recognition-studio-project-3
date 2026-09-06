# Ready-to-post Yellowdig drafts — Oche

These drafts are first-person and deliberately distinguish verified results from planned work.

## Post 1 — Designing the project in measurable stages

**Evidence**

The attached screenshot shows the current project structure and the documented image, video, and camera modes, alongside the privacy and responsible-use boundaries.

**Milestone**

For Project 3, our team is building a Face Recognition Studio in C++17 with OpenCV. I chose an incremental approach: first detect and count faces in a still image, then extend the same processing pipeline to video and webcam input, and only after that test optional matching against permitted reference images.

The application is designed to label unmatched faces as `Unknown`. I am also treating privacy and accuracy as part of the engineering work—not an afterthought—because lighting, pose, image quality, demographic bias, and threshold selection can affect results.

**Lesson**

Privacy and accuracy are not afterthoughts: lighting, pose, image quality, demographic bias, and threshold selection can affect results, and an unmatched face must remain `Unknown`.

**Next step**

My first measurable target is an end-to-end image result: load an image, find the face, draw the result, count it, and save the processed output.

**Screenshot to attach:** `evidence/selected/post-01-project-tree-readme.png`. Do not attach the detection result yet.

## Post 2 — First verified detection result and an honest compatibility issue

**Evidence**

The attached before/after and terminal screenshots show the source image, the annotated output, the exact fallback warning, `Detected 1 face(s)`, and the saved path.

**Milestone**

I have now completed the first end-to-end image milestone. The C++/OpenCV application loaded the test image, detected one face, drew the result, reported `Detected 1 face(s)`, and saved a processed image successfully. The Linux build also passes both current automated checks.

The test also exposed an important issue: the available OpenCV runtime did not accept the YuNet model as expected, so the application used its Haar detection fallback. That means face detection and counting are working, but I am not claiming that YuNet or SFace identity recognition has been validated yet.

**Lesson**

My lesson from this milestone is that a fallback can keep development moving while making the compatibility gap visible.

**Next step**

I will reproduce the build on macOS, inspect the OpenCV/runtime versions, and validate the intended model path before moving to video and webcam testing.

**Screenshots to attach:** `evidence/selected/post-02-synthetic-input-output.png` and `evidence/selected/post-02-synthetic-terminal-detection.png`.

## Post 3 — Making the build reproducible across systems

**Evidence**

The attached privacy-clean evidence screenshot records the Mac dependency versions, successful configure/build/link result, and all nine named CTest checks. The underlying terminal result is preserved separately from this derived posting view.

**Milestone**

I reproduced the C++17 application on an Apple-silicon Mac using AppleClang, CMake, Ninja, and Homebrew OpenCV 4.14.0. After selecting the versioned `opencv@4` package and a clean build directory, CMake configured successfully, the executable linked, and all 9/9 automated tests passed in 2.08 seconds. This gives the project a second verified development environment alongside Linux.

**Lesson**

This step reinforced that reproducibility includes dependency discipline. The unversioned Homebrew package had moved to OpenCV 5, where a fallback API used by the project was removed; explicitly selecting `opencv@4` and rebuilding from a clean directory made the intended API contract reproducible.

**Next step**

My next target is the already prepared non-camera video milestone. A webcam test remains a separate step and will not begin without explicit camera-test confirmation at test time.

**Screenshot to attach:** `evidence/selected/post-03-mac-build-tests.png`.
