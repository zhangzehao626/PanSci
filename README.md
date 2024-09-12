# PanSci
A Panoramic View of Cell Population Dynamics in Mammalian Aging

## Overview
Welcome to the PanSci project repository. This project presents a comprehensive single-cell transcriptome atlas profiling over 20 million cells from >600 mouse tissue samples, providing insights into cellular population dynamics across organs, sexes, genotypes, and ages.

## Data Availability
All data and materials are available for interactive exploration and download:

- Raw FASTQ files, processed count matrices, cell metadata, and gene metadata can be downloaded from NCBI GEO under accession number GSE247719 [https://0-www-ncbi-nlm-nih-gov.brum.beds.ac.uk/geo/query/acc.cgi?acc=GSE247719].
- PanSci data can be interactively accessed in the UCSC cell browser [https://mouse-pansci.cells.ucsc.edu].
- Customized data can mapped to PanSci with the Azimuth application [https://app.azimuth.hubmapconsortium.org/app/mouse-pansci.].

## Methodology
The single-cell datasets were generated using optimized EasySci, an combinatorial indexing based single-cell profiling method. This method offers full-gene-body coverage, high scalability, and low cost platform for organism-scale cell population analysis. Computational analysis pipeline to process raw EasySci data can be found here [https://github.com/JunyueCaoLab/EasySci].

## Analysis functions

### Differential aboundance analysis
To identify changes in cell populations across different conditions (e.g., age, sex, genotype), we employed differential abundance analysis. This analysis was conducted using the following steps:
- Generating organ/tissue-specific cell count matrices across individual mice.
- Normalizing cell counts against the total cell number from the corresponding organ or tissue of each replicates.
- Applying a likelihood-ratio test using the differentialGeneTest() function in Monocle2 (version 2.28.0).
- Setting criteria for significant changes: maximum false discovery rate (FDR) of 0.05 and a fold change higher than 2 between conditions.

### Differential gene expression analysis
To identify differentially expressed genes, we employed the likelihood ratio test to identify genes significantly associated with specific cell types/subtypes in a one vs. all comparison in Monocle2 (version 2.28.0). Criteria for significant changes:
- Maximum false discovery rate (FDR) of 0.05.
- Fold change higher than 2 between top-ranked and second-top clusters.
- Transcript per million over 50 in the highest-ranked cluster.

## Visualization functions

### Cellular level analysis
- UMAP visualization of cell metadata
- UMAP visualization of targeted label
- UMAP visualization of cell density
- Box plot for for cell proportion
- Heatmap for cell proportion across experimental condition (aggregated proportion)
- Heatmap for cell proportion across experimental condition (by replicate)
- Dot plot for cell-type-specific proportion changes
- Stacked bar plot for proportion of cell types from different lineage/organ
- Stacked bar plot with flows for cell population dynamics in different lineage/organ across age groups
- Volcano plot for visualizing differentially aboundant cell types

### Molecular level analysis
- UMAP visualization of targeted gene expression in each cell
- UMAP visualization of targeted gene expression density
- Violin plot for targeted gene expression across cell types/conditions
- Dot plot for targeted gene expression across cell types/conditions
- Heatmap for targeted gene expression across cell types/conditions
- Boxplot for target gene expression
- Lollipop plot for the count of differentially expressed genes


### Generation of customized color palettes
https://medialab.github.io/iwanthue/

## Citation
If you use the data or code in this repository, please cite our manuscript as follows:

- __PanSci__: Zhang, Zehao, et al. "A Panoramic View of Cell Population Dynamics in Mammalian Aging." bioRxiv (2024). DOI: https://doi.org/10.1101/2024.03.01.583001

- __EasySci__: Sziraki, Andras, et al. "A global view of aging and Alzheimer’s pathogenesis-associated cell population dynamics and molecular signatures in human and mouse brains." Nature Genetics 55.12 (2023): 2104-2116. DOI: https://doi.org/10.1038/s41588-023-01572-y

## Contact
For questions or further information, please contact Tommy at zzhang03@rockefeller.edu or raise an issue in this repository.