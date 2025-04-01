process MetaRef {

    publishDir "${projectDir}/data", mode: 'copy', pattern: "RefSeq_out/*"

    input:
    val validRefFiles

    output:
        path "RefSeq_out/*"

    script:

    def metaCmd = """Rscript ${projectDir}/scripts/R/MetaRef.R \
    ${projectDir}/data \
    ${params.reference} \
    ${params.representative} \
    ${params.compress} \
    ${params.caching} \
    ${params.quiet} \
    ${params.split} \
    ${params.mem} \
    ${params.threads} \
    ${params.overwrite} \
    ${projectDir}/data/TaxaDB \
    ${params.target_species} \
    ${params.filter_species} \
    ${projectDir}/bin/tmp"""

    def preCmd = """mkdir -p RefSeq_out && \
    ( cp ${params._RefSeq_path}/*.{fasta,fasta.gz,fa,fna} RefSeq_out/ 2>/dev/null || true )"""

    def cmd = (params.use_RefSeq_files && validRefFiles?.size() > 0) ? preCmd : metaCmd

    if ( params.use_RefSeq_files && validRefFiles?.size() > 0 ) {
         log.info "Found ${validRefFiles.size()} valid RefSeq file(s) in ${params._RefSeq_path}. Copying it to data folder for easy access!!"
    } else if ( params.use_RefSeq_files ) {
         log.info "use_RefSeq_files is ${params.use_RefSeq_files} but no valid files found in ${params._RefSeq_path}. Using MetaRef.R ..."
    } else {
         log.info "use_RefSeq_files is ${params.use_RefSeq_files}. Executing MetaRef.R ..."
    }

    """
    ${cmd}
    """
}