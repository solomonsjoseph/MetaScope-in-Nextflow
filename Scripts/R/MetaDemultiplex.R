#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
barcodeFile <- args[1]
indexFile <- args[2]
readFile <- args[3]
rcBarcodes <- args[4]
hammingDist <- args[5]
threads <- args[6]
quiet <- args[7]
data_dir <- args[8]

demult_output <- file.path(data_dir, "Demultiplexed_files")
dir.create(demult_output, recursive = TRUE, showWarnings = FALSE)

print(demult_output)

demult <- demultiplex(
  barcodeFile = barcodeFile,
  indexFile   = indexFile,
  readFile    = readFile,
  rcBarcodes  = as.logical(rcBarcodes),
  hammingDist = as.numeric(hammingDist),
  location    = demult_output,
  threads     = as.numeric(threads),
  quiet       = as.logical(quiet)
)
# Print a confirmation message and the result of the demultiplexing process.
print("Demultiplexing complete: \n")
print(demult)
print("Demultiplexed files are located at:")
print(demult_output)