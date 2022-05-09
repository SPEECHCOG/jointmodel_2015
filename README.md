# XSL-learning scripts for Räsänen & Rasilo (2015; Psych. Review)

Model and experiment scripts used in Räsänen & Rasilo (2015): A joint-model of word segmentation and meaning acquisition through cross-situational learning. Psychological Review, 122(4), 792–829.

All code in MATLAB, except k-means implementation in `aux/k-means`, where `eucl_dx.c` has to be compiled with mex for non-mac64 platforms. You can also substitute all k-means calls with MATLAB k-means, but compatible results are not guaranteed.

#### Basic structure:

- Each experiment is located in a separate sub-folder (e.g., `exp1/`).
- "CM-fast" (CMF) model is located in `CMF/`.
- Aux scripts are located in `aux_scripts/`

#### About data

Experiments 1 and 2 come with the necessary data files (MBROLA-based syllables) to create the required experimental stimuli. Experiments 3–6 require CAREGIVER corpus. However, pre-computed discretized representations of the corpora are provided in `expX/data/` for default codebook size and talker ID.

#### About the model

The basic "concept matrix" (CM) model is explained in Räsänen & Laine (2012; Pattern Recognition; http://www.sciencedirect.com/science/article/pii/S0031320311002044) and adapted to the experiments here, as explained in the paper (Räsänen & Rasilo, 2015; Psychological Review).

#### Running the experiments

By default, each experiment is executed by running `expX.m` inside the corresponding experiment folder. Experiment folders may also contain additional scripts for result plotting.


#### Reused code

`sigstar.m` by Rob Campbell
`make_MFCC_And_MMFCC2_features.m` by Saikat Chatterjee, Chris Koniaris, Bastiaan Kleijn
`k-means` by Mike Brookes and Chuck Anderson

#### Questions & feedback

The current documentation is sparse (here and inline), so please direct questions at Okko Räsänen (firstname.surname@tuni.fi) in case of issues.
