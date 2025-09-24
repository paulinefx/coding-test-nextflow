process MERGE_BREAKENDS {
    tag "$meta.id"
    label 'process_low'
    
    container 'quay.io/biocontainers/bedtools:2.31.1--hf5e1c6e_1'
    
    publishDir "${params.outdir}/merged", mode: 'copy'
    
    input:
    tuple val(meta), path(bed_file)
    
    output:
    tuple val(meta), path("${meta.id}.merged.bed"), emit: merged_breakends
    path "versions.yml"                           , emit: versions
    
    script:
    """
    # Sort the bed file and merge overlapping intervals
    sort -k1,1 -k2,2n ${bed_file} | \\
    bedtools merge \\
        -i stdin \\
        -d ${params.merge_distance ?: 0} \\
        -c 4 \\
        -o count \\
        > ${meta.id}.merged.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version | sed -e "s/bedtools v//g")
    END_VERSIONS
    """
    
    stub:
    """
    # Create mock output for testing
    echo -e "chr21\\t1000\\t1100\\t2" > ${meta.id}.merged.bed
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: 2.31.1
    END_VERSIONS
    """
}
