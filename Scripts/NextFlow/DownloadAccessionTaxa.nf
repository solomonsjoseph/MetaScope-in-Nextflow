process DownloadAccessionTaxa {

    input:
        val ncbi_accessions_db
        val silva_taxonomy_db
        val blast_16S_db
        val ncbi_accessions_name
        val silva_taxonomy_name
        val blast_16S_name

    script:

    """
    Rscript ${projectDir}/scripts/R/DownloadAccessionTaxa.R \
    ${ncbi_accessions_db} \
    ${silva_taxonomy_db} \
    ${blast_16S_db} \
    ${ncbi_accessions_name} \
    ${silva_taxonomy_name} \
    ${blast_16S_name} \
    ${projectDir}/data

    """
}