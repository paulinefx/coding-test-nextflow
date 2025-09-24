process BEDTOOLS_INTERSECT {
    tag "$meta.id"
    label 'process_low'
    
    container 'quay.io/biocontainers/bedtools:2.31.1--hf5e1c6e_1'
    
    publishDir "${params.outdir}/intersections", mode: 'copy'
    
    input:
    path(asisi_sites)
    tuple val(meta), path(merged_bed)
    
    output:
    tuple val(meta), path("${meta.id}.intersections.bed"), emit: intersections
    path "versions.yml"                                  , emit: versions
    
    script:
    """
    bedtools intersect \\
        -a ${asisi_sites} \\
        -b ${merged_bed} \\
        -wa \\
        -wb \\
        > ${meta.id}.intersections.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version | sed -e "s/bedtools v//g")
    END_VERSIONS
    """
}
