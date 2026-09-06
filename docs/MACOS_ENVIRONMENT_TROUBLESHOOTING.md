# macOS environment troubleshooting record

## Scope

This record documents the environment issues encountered while validating Face
Recognition Studio on an Apple-silicon MacBook Air using Homebrew, CMake, Ninja,
AppleClang and OpenCV. It preserves the symptoms, diagnosis and recovery path so
the setup can be reproduced rather than presented as an unexplained success.

## Environment

- Platform: Apple-silicon MacBook Air (M-series)
- Compiler observed: AppleClang 21.0.0.21000101
- Build system: CMake 4.5 with Ninja
- Initially installed computer-vision library: Homebrew OpenCV 5.0.0
- Project requirement: OpenCV 4.5 or later within the OpenCV 4 API line

No camera access was requested during the setup, compilation or automated-test
steps.

## Issue 1: CMake compatibility policy

### Symptom

The initial Homebrew configuration stopped inside an OpenCV dependency because
newer CMake releases require an explicit minimum compatibility policy.

### Resolution

The configuration was rerun with:

```bash
-DCMAKE_POLICY_VERSION_MINIMUM=3.5
```

This addressed the CMake-policy gate. It did not change application code or
lower the project's own `cmake_minimum_required(VERSION 3.16)` requirement.

## Issue 2: "No tests were found"

### Symptom

`ctest` initially printed:

```text
No tests were found!!!
```

### Root cause

The build directory retained an incomplete or unsuitable CMake configuration.
CTest therefore had no generated test metadata to load.

### Resolution

A new build directory was used instead of deleting or overwriting the earlier
one. After successful configuration, CTest discovered all nine tests.

## Issue 3: OpenCV version mismatch

### Symptom

CMake rejected the available package:

```text
Could not find a configuration file for package "OpenCV" that is compatible
with requested version "4.5".
.../opencv5/OpenCVConfig.cmake, version: 5.0.0
```

### Root cause

The unversioned Homebrew `opencv` formula installed OpenCV 5.0.0. The project
was built and tested against the OpenCV 4 API family.

### Diagnostic attempt

The project requirement was temporarily changed to OpenCV 5 to determine
whether source compatibility remained. Configuration then completed and all
nine tests were registered, but compilation failed with:

```text
error: no type named 'CascadeClassifier' in namespace 'cv'
```

This established that the problem was not merely package discovery: OpenCV 5
removed the legacy cascade API used by the application's fallback detector.
Because the executable was not produced, CTest correctly reported all tests as
`Not Run`; those were downstream build failures, not nine independent test
failures.

### Final resolution

Install and select Homebrew's versioned OpenCV 4 formula:

```bash
brew install opencv@4

cmake -S . -B build-macos-opencv4 -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DOpenCV_DIR=/opt/homebrew/opt/opencv@4/lib/cmake/opencv4

cmake --build build-macos-opencv4
ctest --test-dir build-macos-opencv4 --output-on-failure
```

The dedicated directory `build-macos-opencv4` prevents cached OpenCV 5 paths
from contaminating the corrected build.

## Lessons captured

1. Pin major dependency versions when the application relies on APIs removed in
   a later major release; `opencv@4` is intentional, not incidental.
2. Treat `No tests were found` as a configuration-state symptom and inspect the
   preceding CMake result before interpreting it as a test result.
3. Treat CTest `Not Run` plus `Unable to find executable` as a failed build, then
   inspect verbose compiler output before changing test definitions.
4. Use a fresh build directory when changing generators, dependency versions or
   package locations so stale cache entries cannot produce misleading results.
5. Capture the unsuccessful attempt as evidence of debugging and environment
   validation; do not present it as an application-logic defect.

## Verified resolution

On 5 September 2026, the corrected Apple-silicon build selected Homebrew
OpenCV 4.14.0, configured successfully, linked `face_studio`, and completed the
full suite:

```text
100% tests passed, 0 tests failed out of 9
Total Test time (real) = 2.08 sec
```

The final compatibility correction selects the YuNet model by OpenCV version:
older OpenCV 4 releases use the 2022 graph, while OpenCV 4.10 and later use the
2023 graph with a suitable detector score threshold. The Linux OpenCV 4.6
branch was regression-tested independently and also passed 9/9 tests.

Camera validation remains a separate, explicitly confirmed step and is not
performed by the setup script.
