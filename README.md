# XSL-learning scripts for Räsänen & Rasilo (2015; Psych. Review)

Model and experiment scripts used in Räsänen & Rasilo (2015): A joint-model of word segmentation and meaning acquisition through cross-situational learning. Psychological Review, 122(4), 792–829.

All code in MATLAB, except k-means implementation in `aux/k-means`, where `eucl_dx.c` has to be compiled with mex for non-mac64 platforms. You can also substitute all k-means calls with MATLAB k-means, but compatible results are not guaranteed.

Basic structure:

- Each experiment is located in a separate sub-folder (e.g., `exp1/`).
- "CM-fast" (CMF) model is located in `CMF/`.
- Aux scripts are located in `aux_scripts/`

By default, each experiment is executed by running `expX.m` inside the corresponding experiment folder. Experiment folders may also contain additional scripts for result plotting.

Current documentation is sparse, so please direct questions at Okko Räsänen (firstname.surname@tuni.fi) in case of issues.
