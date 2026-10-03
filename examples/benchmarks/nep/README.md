# Ordinary NEP benchmark inputs

Each runnable leaf contains only `run.in`, `model.xyz`, and `nep.txt`.

Each repository-resident case provides `NVT300/` and `NPT300/` inputs.

`model.xyz` and `nep.txt` are relative symlinks to the deduplicated backing
assets under `structures/` and `potentials/`.

See [`../../README.md`](../../README.md) for the full benchmark description,
53-case matrix, provenance, references, and aggregate result.

The two CuMoTaVW cases require the external 1,221,240-atom structure and are
therefore documented but not materialized as runnable leaf directories here.
