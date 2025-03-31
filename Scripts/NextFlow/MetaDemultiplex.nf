process MetaDemultiplex {

    publishDir "${projectDir}/data", mode: 'copy', pattern: "Demult_out/*"

    input:
        // Accept a single input: the list of valid files computed in the workflow.
        val validDFiles

    output:
        // Capture all output files from the local Demult_out folder.
        path "Demult_out/*"

    script:
    
    def metaCmd = """Rscript ${projectDir}/scripts/R/MetaDemultiplex.R \
    ${params.barcodeFile} \
    ${params.indexFile} \
    ${params.readFile} \
    ${params.rcBarcodes} \
    ${params.hammingDist} \
    ${params.threads} \
    ${params.quiet} \
    ${projectDir}/data"""

    def preCmd = """mkdir -p Demult_out && \
    ( cp ${params.demultiplexed_path}/*.{fastq,fastq.gz,fq,fq.gz} Demult_out/ 2>/dev/null || true )"""

    def cmd = (params.use_demultiplexed_files && validDFiles?.size() > 0) ? preCmd : metaCmd

    if ( params.use_demultiplexed_files && validDFiles?.size() > 0 ) {
         log.info "Found ${validDFiles.size()} valid demultiplexed file(s) in ${params.demultiplexed_path}. Copying it to data folder for easy access!!"
    } else if ( params.use_demultiplexed_files ) {
         log.info "use_demultiplexed_files is ${params.use_demultiplexed_files} but no valid files found in ${params.demultiplexed_path}. Using MetaDemultiplex.R ..."
    } else {
         log.info "use_demultiplexed_files is ${params.use_demultiplexed_files}. Executing MetaDemultiplex.R ..."
    }

    """
    ${cmd}
    """
}