process COLLECT_STATISTICS {
    label 'process_low'
    
    container 'quay.io/biocontainers/coreutils:9.5'
    
    publishDir "${params.outdir}", mode: 'copy'
    
    input:
    path(statistics_files)
    
    output:
    path("all_samples_statistics.tsv"), emit: combined_stats
    path "versions.yml"               , emit: versions
    
    script:
    """
    #!/bin/bash
    
    # Get header from first file
    head -n 1 \$(ls *.statistics.tsv | head -n 1) > all_samples_statistics.tsv
    
    # Concatenate all data rows (excluding headers) and sort by sample name
    for file in *.statistics.tsv; do
        tail -n +2 "\$file"
    done | sort -V >> all_samples_statistics.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: \$(echo \$(sort --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
    END_VERSIONS
    """
}
