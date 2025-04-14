process MetaRef {
     
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
    ${projectDir}/bin \
    ${params._RefSeq_path} \
    ${params.aligner}"""

    """
    ${metaCmd}
    """
}