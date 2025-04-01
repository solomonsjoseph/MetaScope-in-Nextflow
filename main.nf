#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { DownloadAccessionTaxa } from './Scripts/NextFlow/DownloadAccessionTaxa.nf'
include { MetaDemultiplex } from './Scripts/NextFlow/MetaDemultiplex.nf'
include { MetaRef         } from './Scripts/NextFlow//MetaRef.nf'

workflow  {

    // Step 0: Download Taxanomy Data 
    // [Needs to run first and only once] (Use -resume once downloaded)

    Dat_out_ch = DownloadAccessionTaxa(
    params.ncbi_accessions_database, 
    params.ncbi_accessions_name, 
    params.silva_taxonomy_database, 
    params.silva_taxonomy_name, 
    params.blast_16S_database, 
    params.blast_16S_name
    )
    

    // Step 1: MetaDemultiplex

    // Define a list of valid file extensions for the demultiplexed files
    def validDEXT = [".fq.gz", ".fq", ".fastq", ".fastq.gz"]
    
    // Create a list of file patterns by appending each valid extension to the demultiplexed path
    def dfpatterns = validDEXT.collect { "${params.demultiplexed_path}/*${it}" }
    
    // Create a channel from the file patterns if use_demultiplexed_files is true, otherwise create an empty channel
    def validDFilesCh = params.use_demultiplexed_files ? Channel.fromPath(dfpatterns) : Channel.empty()

    // Convert the validFilesCh channel to a list and assign it to validFilesList
    def validDFilesList = validDFilesCh.toList()

    // Channel for demultiplexed files, created by the MetaDemultiplex process using the list of valid files
    demult_files_ch = MetaDemultiplex(validDFiles: validDFilesList)


    // Step 2: MetaRef

    // Define a list of valid file extensions for the RefSeq files
    def validRefEXT = [".fasta", ".fasta.gz", ".fa", ".fna"]

    // Create a list of file patterns by appending each valid extension to the RefSeq path
    def refpatterns = validRefEXT.collect { "${params._RefSeq_path}/*${it}" }

    // Create a channel from the file patterns if use_RefSeq_files is true, otherwise create an empty channel
    def validRefFilesCh = params.use_RefSeq_files ? Channel.fromPath(refpatterns) : Channel.empty()

    // Channel for RefSeq files, created by the MetaRef process using the list of valid files
    MetaRefOut_ch = MetaRef(validRefFiles: validRefFilesCh)
    
}