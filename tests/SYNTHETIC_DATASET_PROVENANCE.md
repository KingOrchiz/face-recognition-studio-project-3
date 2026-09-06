# Synthetic recognition dataset — provenance

All people in this test set are fictional AI-generated subjects. The files were created on 2026-09-05 using the built-in OpenAI image-generation tool and were not captured by a camera. The original 1254×1254 PNGs were deterministically resized to 640×640 with FFmpeg 6.1.1 for the OpenCV 4.6-compatible YuNet test path.

## Reference: Synthetic_A

- File: `tests/known/Synthetic_A.png`
- Role: enrolled reference image
- SHA-256: `6f2b25a86da07081a8ed228bf31d7e76993ecbf04fa54b8d2c9fb96a8c38f488`
- Source and original prompt: `tests/synthetic_portrait_a.provenance.md`

## Known-query variant

- Files: `tests/synthetic_portrait_a_variant.png`, `tests/synthetic_portrait_a_variant_640.png`
- Role: independently generated identity-preserving variation of Synthetic_A
- 640×640 SHA-256: `e417be32b9a2843393d620d9e61afd11d6f763bc809d6e882d6c67fc51c7dc46`
- Allowed edit: slight head turn, neutral expression, gray shirt, warmer studio light
- Identity constraint: preserve the same fictional face, hairstyle, eye colour, facial proportions, and age

## Unknown-query subject

- Files: `tests/synthetic_portrait_b_unknown.png`, `tests/synthetic_portrait_b_unknown_640.png`
- Role: different fictional identity for an `Unknown` decision
- 640×640 SHA-256: `4142bbfb111cb13545a4d15bfbc65607c69c1a8d6a6a3f7ce8bc471d482d8e0e`
- Prompt summary: one fictional adult woman with dark brown skin and short natural black hair, front-facing on a plain gray studio background, with exactly one unobstructed face

## Observed bounded scores

Using YuNet 2022, SFace 2021, one enrolled reference, and 640×640 inputs:

| Query | Cosine score vs Synthetic_A | Threshold | Decision |
|---|---:|---:|---|
| Synthetic_A identity-preserving variant | 0.934496 | 0.363 | Synthetic_A |
| Different synthetic subject | 0.391773 | 0.363 | Synthetic_A — false accept in this test |
| Synthetic_A identity-preserving variant | 0.934496 | 0.400 | Synthetic_A |
| Different synthetic subject | 0.391773 | 0.400 | Unknown |

This tiny synthetic set is suitable for a demonstration and regression check, not for estimating accuracy, demographic fairness, or a deployment threshold.
