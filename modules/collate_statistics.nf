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

# Create header for output
echo -e "sample\tunique_asisi_sites\tmean_breaks_per_asisi\tmean_merged_breakends" > "${meta.id}.statistics.tsv"

# Calculate unique_asisi_sites (number of sites with count > 0)
unique_asisi_sites=\$(awk -F '\t' 'NR>1 && \$4>0 {c++} END {print c+0}' ${counts_file})

# Calculate mean_breaks_per_asisi (mean of counts column, excluding header)
mean_breaks_per_asisi=\$(awk  -F '\t' 'NR>1 {sum+=\$4; n++} END {if(n>0) printf "%.1f", sum/n; else print 0}' ${counts_file})

# Calculate mean_merged_breakends (mean of counts column in merged bed)
mean_merged_breakends=\$(awk -F '\t' '{sum+=\$4; n++} END {if(n>0) printf "%.1f", sum/n; else print 0}' ${merged_bed})

# Output the statistics
echo -e "${meta.id}\t\${unique_asisi_sites}\t\${mean_breaks_per_asisi}\t\${mean_merged_breakends}" >> "${meta.id}.statistics.tsv"

# Create dummy versions.yml to satisfy Nextflow output
echo "dummy version info" > versions.yml
    """
}