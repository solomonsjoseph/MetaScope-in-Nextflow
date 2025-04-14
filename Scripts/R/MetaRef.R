#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

# Ensure all required arguments are provided
if (length(args) < 14) {
  stop("Not all required arguments are provided.")
}

data_dir <- args[1]
reference <- args[2]
representative <- args[3]
compress <- args[4]
caching <- args[5]
quiet <- args[6]
split <- args[7]
mem <- args[8]
threads <- args[9]
overwrite <- args[10]
downloaded_accessions <- args[11]
bin_dir <- args[12]
RefSeq_path <- args[13]
aligner <- args[14]

# Ensure target_species and filter_species are provided if RefSeq_path is not provided
target_species <- if (length(args) >= 15) strsplit(args[15], split = ",") else list()
filter_species <- if (length(args) >= 16) strsplit(args[16], split = ",") else list()

# Check if aligner is provided
if (is.null(aligner) || aligner == "") {
  stop('Aligner not specified. Use "bowtie2" or "subread".')
}

# Validate required arguments based on aligner
if (aligner == "bowtie2") {
  if (is.null(threads) || is.null(overwrite)) {
    stop('For bowtie2 aligner, both threads and overwrite arguments are required.')
  }
} else if (aligner == "subread") {
  if (is.null(split) || is.null(mem)) {
    stop('For subread aligner, both split and mem arguments are required.')
  }
} else {
  stop('Invalid aligner specified. Use "bowtie2" or "subread".')
}

# Create necessary directories
dir.create(bin_dir, recursive = TRUE, showWarnings = FALSE)
temp_dir <- file.path(bin_dir, "tmp")
dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)
indices_dir <- file.path(data_dir, "indices_dir")
dir.create(indices_dir, recursive = TRUE, showWarnings = FALSE)

library(MetaScope)

# Handle RefSeq path or download species
if (!is.null(RefSeq_path) && length(RefSeq_path) == 1 && RefSeq_path != "") {
  patterns <- c("fasta", "fa", "fna")
  pattern <- paste(paste0("\\.", patterns, "(\\.gz)?$"), collapse = "|")
  refseq_files <- list.files(RefSeq_path, pattern = pattern, full.names = TRUE, recursive = TRUE)
  
  if (length(refseq_files) == 0) {
    stop("No RefSeq files found in the provided directory.")
  }
} else {
  if (length(target_species) == 0 || length(filter_species) == 0) {
    stop('Either provide RefSeq_path or both target_species and filter_species.')
  }
  
  RefSeq_path <- file.path(data_dir, "Reflib")
  dir.create(RefSeq_path, recursive = TRUE, showWarnings = FALSE)
  target_ref_temp <- file.path(temp_dir, "target_ref")
  dir.create(target_ref_temp, recursive = TRUE, showWarnings = FALSE)
  filter_ref_temp <- file.path(temp_dir, "filter_ref")
  dir.create(filter_ref_temp, recursive = TRUE, showWarnings = FALSE)

  download_species <- function(species_list, out_dir) {
    sapply(
      species_list,
      download_refseq,
      reference      = reference,
      representative = representative,
      compress       = compress,
      out_dir        = out_dir,
      caching        = caching,
      quiet          = quiet,
      accession_path = downloaded_accessions
    )
  }

  target_species_vector <- tolower(unlist(target_species))
  filter_species_vector <- tolower(unlist(filter_species))

  download_species(target_species_vector, target_ref_temp)
  download_species(filter_species_vector, filter_ref_temp)
  
  refseq_files <- c(target_ref_temp, filter_ref_temp)
}

# Define the function to get the base name
get_base_name <- function(file) {
  sub("\\..*$", "", basename(file))
}

# Define index creation functions
create_bowtie2_index <- function(ref_file, lib_dir, lib_name, bowtie2_build_options = NULL) {
  mk_bowtie_index(
    ref_dir   = dirname(ref_file),
    lib_dir   = lib_dir,
    lib_name  = lib_name,
    bowtie2_build_options = bowtie2_build_options,
    threads   = threads,
    overwrite = overwrite
  )
}

create_subread_index <- function(ref_file, index_temp) {
  original_wd <- getwd()
  setwd(index_temp)
  mk_subread_index(
    ref_lib = ref_file,
    split   = split,
    mem     = mem,
    quiet   = quiet
  )
  setwd(original_wd)
}

# Create indices based on provided aligner
process_file <- function(file) {
  file_base <- get_base_name(file)
  file_dir <- file.path(indices_dir, file_base)
  dir.create(file_dir, recursive = TRUE, showWarnings = FALSE)
  
  if (aligner == "bowtie2") {
    create_bowtie2_index(file, file_dir, file_base)
  } else if (aligner == "subread") {
    create_subread_index(file, file_dir)
  } else {
    stop('Invalid aligner specified. Use "bowtie2" or "subread".')
  }
}

tryCatch({
  if (length(refseq_files) == 1) {
    process_file(refseq_files[1])
  } else {
    for (file in refseq_files) {
      process_file(file)
    }
  }
}, error = function(e) {
  cat("Error encountered:", e$message, "\n")
})

cat("Reference genome indexing complete. Index files saved to", indices_dir, "\n")