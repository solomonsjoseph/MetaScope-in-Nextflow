#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
data_dir <- args[1]
reference <- args[2]
representative <- args[2]
compress <- args[3]
caching <- args[4]
quiet <- args[5]
split <- args[6]
mem <- args[7]
threads <- args[8]
overwrite <- args[9]
downloaded_accessions <- args[10]
target_species <- args[11]
filter_species <- args[12]
temp_dir <- args[13]

library(MetaScope)

RefSeq_path <- file.path(data_dir, "Reflib")
if (!dir.exists(base_dir)) dir.create(base_dir, recursive = TRUE)

indices_dir <- file.path(RefSeq_path, "indices")
if (!dir.exists(indices_dir)) dir.create(indices_dir)

download_species <- function(species_list, out_dir) {
  if (length(species_list) == 1) {
    download_refseq(
      taxon          = species_list[[1]],
      reference      = reference,
      representative = representative,
      compress       = compress,
      out_dir        = out_dir,
      caching        = caching,
      quiet          = quiet,
      accession_path = downloaded_accessions
    )
  } else {
    sapply(
      species_list,
      download_refseq,
      reference      = reference,
      representative = representation,
      compress       = compress,
      out_dir        = out_dir,
      caching        = caching,
      quiet          = quiet,
      accession_path = download_accessions
    )
  }
}

target_species_vector <- tolower(eval(parse(text = target_species)))
filter_species_vector <- tolower(eval(parse(text = filter_species)))

target_ref_temp <- file.path(temp_dir, "target_ref")
dir.create(target_ref_temp, recursive = TRUE)
filter_ref_temp <- file.path(temp_dir, "filter_ref")
dir.create(filter_ref_temp, recursive = TRUE)
index_temp <- file.path(temp_dir, "index_tmp")
dir.create(index_temp, recursive = TRUE)

download_species(target_species_vector, target_ref_temp)
download_species(filter_species_vector, filter_ref_temp)

create_bowtie2_index <- function(ref_dir, lib_dir, lib_name) {
  mk_bowtie_index(
    ref_dir   = ref_dir,
    lib_dir   = lib_dir,
    lib_name  = lib_name,
    threads   = threads,
    overwrite = overwrite
  )
}

create_subread_index <- function(ref_lib, index_temp) {
  original_wd <- getwd()
  setwd(index_temp)
  mk_subread_index(
    ref_lib = ref_lib,
    split   = split,
    mem     = mem,
    quiet   = quiet
  )
  setwd(original_wd)
}

if (aligner == "bowtie2") {
  create_bowtie2_index(target_ref_temp, index_temp, "target")
  create_bowtie2_index(filter_ref_temp, index_temp, "filter")
} else if (aligner == "subread") {
  create_subread_index(target_ref_temp, index_temp)
  create_subread_index(filter_ref_temp, index_temp)
} else {
  stop('Invalid aligner specified. Use "bowtie2" or "subread".')
}

file.copy(
  list.files(index_temp, full.names = TRUE),
  indices_dir,
  recursive = TRUE,
  overwrite = TRUE
)

cat("Reference genome indexing complete. Index files saved to", indices_dir, "\n")