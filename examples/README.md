# WPE examples and benchmarks

This directory contains a minimal WPE quickstart and the ordinary-NEP input set
used to benchmark WPE against upstream GPUMD.

## What was benchmarked

- **53 geometry × potential cases**
- **27 physical structure seeds**
- **21 distinct NEP model files**
- two protocols per case: **NVT300** and **NPT300**
- **106 formal tasks**
- three paired/interleaved GPUMD-vs-WPE repeats per task
- NVIDIA RTX 5090 GPUs

The paired order was `GPUMD -> WPE`, `WPE -> GPUMD`, `GPUMD -> WPE`.
Each process used a 100-step warm-up and a 500-step timed production run.

### Frozen aggregate result

| metric | WPE speedup over upstream GPUMD |
|---|---:|
| all 106 NVT300 + NPT300 tasks, paired geometric mean | **3.493627852×** |
| NVT300, 53 tasks | **3.687863132×** |
| NPT300, 53 tasks | **3.309622709×** |
| minimum task speedup | **2.358937333×** |
| maximum task speedup | **5.615665431×** |
| tasks below 0.99× | **0** |

Raw performance-result files are intentionally not stored in the public examples
tree; the frozen aggregate result is recorded here. NVT300 and NPT300 were
measured in separate closed RTX 5090 campaigns using the same benchmark matrix
and the same paired/interleaved three-repeat protocol.

## Input protocol

Every runnable benchmark leaf contains only `run.in`, `model.xyz`, and `nep.txt`.
The structure and potential files are relative symbolic links to deduplicated
backing assets under `benchmarks/nep/structures/` and `benchmarks/nep/potentials/`.

Ordinary NVT300:

```text
replicate RX RY RZ
potential nep.txt
velocity 300 seed 20260903
time_step 1.0

ensemble nvt_nhc 300 300 100
run 100
ensemble nvt_nhc 300 300 100
run 500
```

Ordinary NPT300 (orthogonal 3D):

```text
replicate RX RY RZ
potential nep.txt
velocity 300 seed 20260903
time_step 1.0

ensemble npt_scr 300 300 100 0 0 0 100 100 100 1000
run 100
ensemble npt_scr 300 300 100 0 0 0 100 100 100 1000
run 500
```

For slab and non-orthogonal cells, the NPT input preserves the validated
box constraints used in the benchmark: the vacuum-normal component is frozen
where applicable, and non-orthogonal cells use the six-component `npt_scr`
form with shear box degrees of freedom frozen. The exact input is preserved
in each leaf `run.in`.

Bulk-water cases use `time_step 0.5`; the exact benchmark input is preserved
in each leaf `run.in`.

## Provenance

Structure provenance and potential provenance are recorded separately.

- Publication/repository-derived inputs include Al2O3, BaTiO3, HfO2, ICOF-Na,
  LiH, LLZO, Mg-water/MgOH, PbTe, ZrO2, graphene-hBN, and the water families.
- Official GPUMD assets provide the GPUMD PbTe example, baseline-PbTe model,
  and the three Si NEP4 complexity-control models.
- NEP89 is the published 89-element general-purpose NEP.
- UNEP16 is the published 16-element metal/alloy potential.
- Locally constructed/reused simple benchmark geometries are used where no
  publication-specific coordinate set is required: a 4-atom orthorhombic
  graphene cell; a conventional 4-atom fcc Cu cell; the frozen 8-atom
  diamond-C base; an audited ordered zincblende-type SiGe base; and audited
  standard Ni/Al/Fe/W/Mg/Ti crystal geometries reused from the classical
  validation suite. These are geometry sources only; the NEP benchmark still
  uses the NEP models listed below.
- The Si(111) slab is an internally audited benchmark slab geometry.

The 1,221,240-atom CuMoTaVW structure was part of the frozen benchmark but is
not duplicated into this repository because of its size. Its provenance and
expected SHA256 remain under `benchmarks/nep/structures/CuMoTaVW/`.

## 53 benchmark cases

| case | geometry | potential | seed atoms | replicate | final atoms | structure DOI/reference | potential DOI/reference |
|---|---|---|---:|---:|---:|---|---|
| `Al2O3__NEP89` | Al2O3 | NEP89 | 80 | `17×17×17` | 393,040 | `10.1073/pnas.2510746122` | `10.1038/s43588-026-01009-6` |
| `Al2O3__public-2025` | Al2O3 | public-2025 | 80 | `17×17×17` | 393,040 | `10.1073/pnas.2510746122` | `10.1073/pnas.2510746122` |
| `BaTiO3__NEP89` | BaTiO3 | NEP89 | 70 | `31×31×6` | 403,620 | `10.1021/acs.jctc.6c00146` | `10.1038/s43588-026-01009-6` |
| `BaTiO3__Zenodo-2026` | BaTiO3 | Zenodo-2026 | 70 | `31×31×6` | 403,620 | `10.1021/acs.jctc.6c00146` | `10.1021/acs.jctc.6c00146` |
| `graphene__C-2024` | graphene | C-2024 | 4 | `240×416×1` | 399,360 | — | `10.1088/1361-648X/ad31c2` |
| `graphene__NEP89` | graphene | NEP89 | 4 | `240×416×1` | 399,360 | — | `10.1038/s43588-026-01009-6` |
| `fcc-Cu__NEP89` | Cu | NEP89 | 4 | `50×50×50` | 500,000 | — | `10.1038/s43588-026-01009-6` |
| `fcc-Cu__UNEP16` | Cu | UNEP16 | 4 | `50×50×50` | 500,000 | — | `10.1038/s41467-024-54554-x` |
| `CuMoTaVW__NEP89` | CuMoTaVW | NEP89 | 1,221,240 | `1×1×1` | 1,221,240 | `10.1038/s41467-024-54554-x` | `10.1038/s43588-026-01009-6` |
| `CuMoTaVW__UNEP16` | CuMoTaVW | UNEP16 | 1,221,240 | `1×1×1` | 1,221,240 | `10.1038/s41467-024-54554-x` | `10.1038/s41467-024-54554-x` |
| `HfO2__MatPL` | HfO2 | MatPL | 12 | `35×35×35` | 514,500 | `10.26434/chemrxiv.15001665/v3` | `10.1103/PhysRevB.108.045422`; `10.26434/chemrxiv.15001665/v3` |
| `HfO2__NEP89` | HfO2 | NEP89 | 12 | `35×35×35` | 514,500 | `10.26434/chemrxiv.15001665/v3` | `10.1038/s43588-026-01009-6` |
| `ICOF-Na__NEP89` | ICOF-Na | NEP89 | 104 | `15×17×15` | 397,800 | `10.1016/j.mtphys.2025.101724` | `10.1038/s43588-026-01009-6` |
| `ICOF-Na__public-2025` | ICOF-Na | public-2025 | 104 | `15×17×15` | 397,800 | `10.1016/j.mtphys.2025.101724` | `10.1016/j.mtphys.2025.101724` |
| `LiH__NEP89` | LiH | NEP89 | 250 | `11×12×12` | 396,000 | `10.1063/5.0241006` | `10.1038/s43588-026-01009-6` |
| `LiH__public-2024` | LiH | public-2024 | 250 | `11×12×12` | 396,000 | `10.1063/5.0241006` | `10.1063/5.0241006` |
| `LLZO__NEP89` | LLZO | NEP89 | 192 | `12×13×13` | 389,376 | `10.1021/acs.jctc.6c00146` | `10.1038/s43588-026-01009-6` |
| `LLZO__Zenodo-2026` | LLZO | Zenodo-2026 | 192 | `12×13×13` | 389,376 | `10.1021/acs.jctc.6c00146` | `10.1021/acs.jctc.6c00146` |
| `Mg-water__NEP89` | Mg-water | NEP89 | 286 | `40×35×1` | 400,400 | `10.1021/acs.jctc.6c00146` | `10.1038/s43588-026-01009-6` |
| `Mg-water__Zenodo-2026` | Mg-water | Zenodo-2026 | 286 | `40×35×1` | 400,400 | `10.1021/acs.jctc.6c00146` | `10.1021/acs.jctc.6c00146` |
| `PbTe-GPUMD__NEP89` | PbTe | NEP89 | 250 | `12×12×12` | 432,000 | `10.1063/5.0106617` | `10.1038/s43588-026-01009-6` |
| `PbTe-GPUMD__baseline-PbTe` | PbTe | baseline-PbTe | 250 | `12×12×12` | 432,000 | `10.1063/5.0106617` | `10.1063/5.0106617` |
| `PbTe-Wu__Wu-2024` | PbTe | Wu-2024 | 216 | `12×12×13` | 404,352 | `10.1063/5.0213811` | `10.1063/5.0213811` |
| `PbTe-Wu__NEP89` | PbTe | NEP89 | 216 | `12×12×13` | 404,352 | `10.1063/5.0213811` | `10.1038/s43588-026-01009-6` |
| `Si111-slab__NEP4-3body` | Si111-slab | NEP4-3body | 146 | `37×74×1` | 399,748 | — | `10.1063/5.0106617` |
| `Si111-slab__NEP4-4body` | Si111-slab | NEP4-4body | 146 | `37×74×1` | 399,748 | — | `10.1063/5.0106617` |
| `Si111-slab__NEP4-5body` | Si111-slab | NEP4-5body | 146 | `37×74×1` | 399,748 | — | `10.1063/5.0106617` |
| `Si111-slab__NEP89` | Si111-slab | NEP89 | 146 | `37×74×1` | 399,748 | — | `10.1038/s43588-026-01009-6` |
| `diamond-Si__Wu-2024` | diamond-Si | Wu-2024 | 64 | `18×18×19` | 393,984 | `10.1063/5.0213811` | `10.1063/5.0213811` |
| `diamond-Si__NEP89` | diamond-Si | NEP89 | 64 | `18×18×19` | 393,984 | `10.1063/5.0213811` | `10.1038/s43588-026-01009-6` |
| `ZrO2__NEP89` | ZrO2 | NEP89 | 12 | `33×33×31` | 405,108 | `10.1073/pnas.2510746122` | `10.1038/s43588-026-01009-6` |
| `ZrO2__public-2025` | ZrO2 | public-2025 | 12 | `33×33×31` | 405,108 | `10.1073/pnas.2510746122` | `10.1073/pnas.2510746122` |
| `gr-hBN__NEP89` | gr-hBN | NEP89 | 64 | `56×112×1` | 401,408 | `10.1038/s41524-025-01885-y` | `10.1038/s43588-026-01009-6` |
| `gr-hBN__public-2025` | gr-hBN | public-2025 | 64 | `56×112×1` | 401,408 | `10.1038/s41524-025-01885-y` | `10.1038/s41524-025-01885-y` |
| `water-MatPL__MatPL` | water-MatPL | MatPL | 648 | `9×9×9` | 472,392 | `10.26434/chemrxiv.15001665/v3` | `10.1063/5.0147039`; `10.26434/chemrxiv.15001665/v3` |
| `water-MatPL__NEP89` | water-MatPL | NEP89 | 648 | `9×9×9` | 472,392 | `10.26434/chemrxiv.15001665/v3` | `10.1038/s43588-026-01009-6` |
| `water-GPUMD1536__NEP89` | water-GPUMD1536 | NEP89 | 1,536 | `6×6×6` | 331,776 | `10.1063/5.0241006` | `10.1038/s43588-026-01009-6` |
| `water-GPUMD1536__baseline-water` | water-GPUMD1536 | baseline-water | 1,536 | `6×6×6` | 331,776 | `10.1063/5.0241006` | `10.1038/s41524-025-01777-1` |
| `water-Zenodo__Zenodo-2026` | water-Zenodo | Zenodo-2026 | 384 | `10×10×10` | 384,000 | `10.1021/acs.jctc.6c00146` | `10.1021/acs.jctc.6c00146` |
| `water-Zenodo__NEP89` | water-Zenodo | NEP89 | 384 | `10×10×10` | 384,000 | `10.1021/acs.jctc.6c00146` | `10.1038/s43588-026-01009-6` |
| `diamond-C__NEP89` | diamond-C | NEP89 | 8 | `40×40×41` | 524,800 | — | `10.1038/s43588-026-01009-6` |
| `SiGe-zincblende__NEP89` | SiGe-zincblende | NEP89 | 8 | `37×37×37` | 405,224 | — | `10.1038/s43588-026-01009-6` |
| `fcc-Ni__NEP89` | Ni | NEP89 | 2,048 | `6×6×6` | 442,368 | — | `10.1038/s43588-026-01009-6` |
| `fcc-Ni__UNEP16` | Ni | UNEP16 | 2,048 | `6×6×6` | 442,368 | — | `10.1038/s41467-024-54554-x` |
| `fcc-Al__NEP89` | Al | NEP89 | 2,048 | `6×6×6` | 442,368 | — | `10.1038/s43588-026-01009-6` |
| `fcc-Al__UNEP16` | Al | UNEP16 | 2,048 | `6×6×6` | 442,368 | — | `10.1038/s41467-024-54554-x` |
| `bcc-Fe__NEP89` | Fe | NEP89 | 2,000 | `6×6×6` | 432,000 | — | `10.1038/s43588-026-01009-6` |
| `bcc-W__NEP89` | W | NEP89 | 2,000 | `6×6×6` | 432,000 | — | `10.1038/s43588-026-01009-6` |
| `bcc-W__UNEP16` | W | UNEP16 | 2,000 | `6×6×6` | 432,000 | — | `10.1038/s41467-024-54554-x` |
| `hcp-Mg__NEP89` | Mg | NEP89 | 2,048 | `6×6×6` | 442,368 | — | `10.1038/s43588-026-01009-6` |
| `hcp-Mg__UNEP16` | Mg | UNEP16 | 2,048 | `6×6×6` | 442,368 | — | `10.1038/s41467-024-54554-x` |
| `hcp-Ti__NEP89` | Ti | NEP89 | 2,048 | `6×6×6` | 442,368 | — | `10.1038/s43588-026-01009-6` |
| `hcp-Ti__UNEP16` | Ti | UNEP16 | 2,048 | `6×6×6` | 442,368 | — | `10.1038/s41467-024-54554-x` |

## References

- **Liang-2026-NEP89** — Ting Liang et al., *NEP89: universal neuroevolution potential for inorganic and organic materials across 89 elements*, Nature Computational Science 6, 789-801 (2026). DOI `10.1038/s43588-026-01009-6`. Dataset `10.5281/zenodo.19440423`. Official NEP89 model family.
- **Song-2024-UNEP16** — Keke Song et al., *General-purpose machine-learned potential for 16 elemental metals and their alloys*, Nature Communications 15, 10208 (2024). DOI `10.1038/s41467-024-54554-x`. Dataset `10.5281/zenodo.11533864`. Official UNEP-v1; CuMoTaVW structure provenance.
- **Fan-2026-qNEP** — Z. Fan et al., *qNEP: A Highly Efficient Neuroevolution Potential with Dynamic Charges for Large-Scale Atomistic Simulations*, JCTC 22, 4787-4801 (2026). DOI `10.1021/acs.jctc.6c00146`. Dataset `10.5281/zenodo.18335947`. Companion conventional NEP models/geometries.
- **Yang-2025-Al2O3-ZrO2** — Rui Yang et al., *Atomic armor for thermal stability in nanoporous structures*, PNAS (2025). DOI `10.1073/pnas.2510746122`. Al2O3 and ZrO2.
- **Li-2025-ICOF** — Ke Li et al., *Decoding the Thermal Conductivity of Ionic Covalent Organic Frameworks: Optical Phonons as Key Determinants Revealed by Neuroevolution Potential*, Materials Today Physics 54, 101724 (2025). DOI `10.1016/j.mtphys.2025.101724`. ICOF-Na.
- **Ying-2025-LiH** — Penghua Ying et al., *Highly efficient path-integral molecular dynamics simulations with GPUMD using neuroevolution potentials: Case studies on thermal properties of materials*, JCP 162, 064109 (2025). DOI `10.1063/5.0241006`. LiH and GPUMD PIMD water workflow provenance.
- **Wu-2024** — Xiguang Wu et al., *Correcting force error-induced underestimation of lattice thermal conductivity in machine learning molecular dynamics*, JCP 161, 014103 (2024). DOI `10.1063/5.0213811`. PbTe and Si.
- **Liang-2026-Gr-hBN** — Ting Liang et al., *Probing the ideal limit of interfacial thermal conductance in two-dimensional van der Waals heterostructures*, npj Computational Materials 12, 11 (2026). DOI `10.1038/s41524-025-01885-y`. Gr/h-BN.
- **Zhang-2023-HfO2** — Honggang Zhang et al., *Vibrational anharmonicity results in decreased thermal conductivity of amorphous HfO2 at high temperature*, Physical Review B 108, 045422 (2023). DOI `10.1103/PhysRevB.108.045422`. HfO2 NEP.
- **Xu-2023-water** — Ke Xu et al., *Accurate prediction of heat conductivity of water by a neuroevolution potential*, JCP 158, 204114 (2023). DOI `10.1063/5.0147039`. MatPL-water NEP.
- **Xu-2025-NEP-MB-pol** — Ke Xu et al., *NEP-MB-pol: a unified machine-learned framework for fast and accurate prediction of water's thermodynamic and transport properties*, npj Computational Materials 11, 279 (2025). DOI `10.1038/s41524-025-01777-1`. Dataset `10.5281/zenodo.15033656`. baseline-water.
- **Fan-2022-GPUMD** — Z. Fan et al., *GPUMD: A package for constructing accurate machine-learned potentials and performing highly efficient atomistic simulations*, JCP 157, 114801 (2022). DOI `10.1063/5.0106617`. Official PbTe example and bundled Si NEP4 models.
- **Fan-2024-C** — Z. Fan et al., *Combining linear-scaling quantum transport and machine-learning molecular dynamics to study thermal and electronic transports in complex materials*, J. Phys.: Condens. Matter 36, 245901 (2024). DOI `10.1088/1361-648X/ad31c2`. C_2024_NEP4.
- **Suo-MatPL** — P. Suo et al., *Towards Scalable and Efficient Machine-Learning Force Fields: The MatPL package and Its Advancements on Neuroevolution Potentials*, ChemRxiv v3. DOI `10.26434/chemrxiv.15001665/v3`. MatPL HfO2/water benchmark package.

## Directory layout

```text
examples/
├── README.md
├── quickstart/nep/
│   ├── model.xyz
│   ├── nep.txt
│   └── run.in
└── benchmarks/nep/
    ├── structures/
    ├── potentials/
    └── cases/<case>/
        ├── NVT300/{model.xyz,nep.txt,run.in}
        └── NPT300/{model.xyz,nep.txt,run.in}
```
