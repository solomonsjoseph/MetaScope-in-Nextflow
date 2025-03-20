#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
NCBI_accessions_db <- args[1]
NCBI_accessions_name <- args[2]
silva_taxonomy_db <- args[3]
silva_taxonomy_name <- args[4]
blast_16S_db <- args[5]
blast_16S_name <- args[6]
data_dir <- args[7]


library(MetaScope)
DownloadAccessionFiles <- file.path(data_dir, "TaxaDB")
dir.create(DownloadAccessionFiles, recursive = TRUE, showWarnings = FALSE)

# Download the accession files
download_accessions(
  DownloadAccessionFiles,
  NCBI_accessions_database = as.logical(NCBI_accessions_db),
  NCBI_accessions_name = NCBI_accessions_name,
  silva_taxonomy_database = as.logical(silva_taxonomy_db),
  silva_taxonomy_name = silva_taxonomy_name,
  blast_16S_database = as.logical(blast_16S_db),
  blast_16S_name = blast_16S_name
)