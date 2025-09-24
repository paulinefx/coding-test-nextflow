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

    # Calculate summary statistics
    total_samples=\$(grep -v '^Sample' all_samples_statistics.tsv | wc -l)
    total_intersections=\$(grep -v '^Sample' all_samples_statistics.tsv | awk -F'\\t' '{sum += \$2} END {print sum}')
    mean_intersections=\$(grep -v '^Sample' all_samples_statistics.tsv | awk -F'\\t' '{sum += \$2} END {if (NR > 0) print sum/NR; else print 0}')

    # Append summary line
    echo -e "SUMMARY\\tTotal_Samples: \$total_samples\\tTotal_Intersections: \$total_intersections\\tMean_Intersections: \$mean_intersections" >> all_samples_statistics.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: \$(echo \$(sort --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
    END_VERSIONS
    """
}
