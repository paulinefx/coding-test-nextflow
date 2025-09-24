process COLLATE_STATISTICS {
    tag "$meta.id"
    label 'process_low'
    
    container 'quay.io/biocontainers/coreutils:9.5'
    
    publishDir "${params.outdir}/statistics", mode: 'copy'
    
    input:
    tuple val(meta), path(counts_file)
    tuple val(meta2), path(merged_bed)
    
    output:
    tuple val(meta), path("${meta.id}.statistics.tsv"), emit: statistics
    path "versions.yml"                               , emit: versions
    
    script:
    """
    #!/bin/bash
    
    # Create header
    echo -e "sample\\tunique_asisi_sites\\tmean_breaks_per_asisi\\tmean_merged_breakends" > ${meta.id}.statistics.tsv
    
    # Calculate statistics
    sample_id="${meta.id}"
    
    # Count unique AsiSI sites with intersections (excluding header)
    unique_sites=\$(tail -n +2 ${counts_file} | wc -l)
    
    # Calculate mean breaks per AsiSI site (excluding header)
    if [ \$unique_sites -gt 0 ]; then
        mean_breaks=\$(tail -n +2 ${counts_file} | awk '{sum += \$4; count++} END {if (count > 0) print sum/count; else print 0}')
    else
        mean_breaks=0
    fi
    
    # Calculate mean merged breakends
    if [ -s ${merged_bed} ]; then
        mean_merged=\$(awk '{sum += \$4; count++} END {if (count > 0) print sum/count; else print 0}' ${merged_bed})
    else
        mean_merged=0
    fi
    
    # Output the statistics
    echo -e "\${sample_id}\\t\${unique_sites}\\t\${mean_breaks}\\t\${mean_merged}" >> ${meta.id}.statistics.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: \$(echo \$(sort --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
    END_VERSIONS
    """
}
