# CuMoTaVW benchmark structure

The benchmark uses the original 1,221,240-atom CuMoTaVW structure and does not duplicate that large file in this repository.

- Reference: `Song-2024-UNEP16`
- Expected SHA256: `fc5dfcf393d3266b6ce44bf95cdcdd4c1c607f973bae71d2e34083997f62fea6`

Set `WPE_BENCHMARK_EXTERNAL_MODEL=/path/to/model.xyz` when materializing a CuMoTaVW benchmark case. The preparation script verifies this SHA256 before running.
