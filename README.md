# MetaScope-in-Nextflow

A Nextflow implementation of the MetaScope pipeline for metagenomics analysis. This workflow provides a modular and reproducible approach to taxonomic classification and metagenomic analysis using the R package MetaScope.

## Overview

This pipeline provides a streamlined workflow for metagenomic analysis with three main components:

1. **DownloadAccessionTaxa** - Downloads and prepares taxonomic databases
2. **MetaDemultiplex** - Demultiplexes sequencing data using barcodes
3. **MetaRef** - Creates reference indices for mapping

## Prerequisites

- [Nextflow](https://www.nextflow.io/) (version 20.10.0 or later)
- [R](https://www.r-project.org/) with the following packages:
  - [MetaScope](https://bioconductor.org/packages/release/bioc/html/MetaScope.html)
- For Bowtie2 indexing:
  - [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
- For Subread indexing:
  - [Subread](http://subread.sourceforge.net/)

## Installation

Clone this repository:

```bash
git clone https://github.com/yourusername/MetaScope-in-Nextflow.git
cd MetaScope-in-Nextflow
```

## Configuration

Edit the `nextflow.config` file to set your parameters:

```groovy
params {
    // Download AccessionTaxa
    ncbi_accessions_database = 'true'
    ncbi_accessions_name = 'accessionTaxa.sql'
    silva_taxonomy_database = 'true'
    silva_taxonomy_name = 'all_silva_headers.rds'
    blast_16S_database = 'true'
    blast_16S_name = '16S_ribosomal_RNA'

    // MetaDemultiplex
    use_demultiplexed_files = true
    demultiplexed_path = "/path/to/demultiplexed_files"
    barcodeFile      = '/path/to/barcode_file'
    indexFile        = '/path/to/index_file'
    readFile         = '/path/to/read_file'
    rcBarcodes       = true
    hammingDist      = 2
    threads          = 4
    quiet            = false

    // MetaRef
    use_RefSeq_files = true
    _RefSeq_path = "/path/to/RefSeq_files"
    reference = true
    representative = false
    compress = true
    caching = true
    quiet = true
    split = 4
    mem = 8000
    threads = 4
    overwrite = true
    target_species = "" // add target species like "Escherichia coli, bacteria, archaea"
    filter_species = "" // add filter species like "Human, other filter species"
}
```

## Usage

Run the full pipeline:

```bash
nextflow run main.nf
```

Run with resume option (after database download):

```bash
nextflow run main.nf -resume
```

### Workflow Steps

The pipeline consists of three main steps:

#### 1. DownloadAccessionTaxa

Downloads necessary taxonomy data from NCBI and SILVA databases. This step only needs to be run once. After the first run, use the `-resume` flag to skip this step.

#### 2. MetaDemultiplex

Processes raw sequencing data using barcodes to demultiplex reads. You can either:
- Use the MetaScope demultiplexing algorithm by setting paths to barcode, index, and read files
- Skip demultiplexing by providing already demultiplexed files (set `use_demultiplexed_files = true`)

#### 3. MetaRef

Creates reference indices for mapping. You can either:
- Provide RefSeq files directly by setting `_RefSeq_path`
- Download specific reference genomes by specifying `target_species` and `filter_species`

The pipeline supports two aligners:
- Bowtie2
- Subread

## Project Structure

```
├── main.nf                 # Main Nextflow workflow
├── nextflow.config         # Configuration file
└── Scripts/
    ├── NextFlow/           # Nextflow process definitions
    │   ├── DownloadAccessionTaxa.nf
    │   ├── MetaDemultiplex.nf
    │   └── MetaRef.nf
    └── R/                  # R scripts called by Nextflow processes
        ├── DownloadAccessionTaxa.R
        ├── MetaDemultiplex.R
        └── MetaRef.R
```

## Output

The pipeline generates the following outputs:

- **data/TaxaDB/** - Taxonomic databases
- **data/Demultiplexed_files/** - Demultiplexed FASTQ files
- **data/indices_dir/** - Reference indices for alignment

## License

[Specify your license here]

## Citation

If you use this pipeline, please cite:

- Nextflow: Di Tommaso, P., Chatzou, M., Floden, E. W., Barja, P. P., Palumbo, E., & Notredame, C. (2017). Nextflow enables reproducible computational workflows. Nature Biotechnology, 35(4), 316-319.
- MetaScope: [Add MetaScope citation]

## Contact

Solomon - help needed 
