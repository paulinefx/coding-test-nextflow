process COUNT_INTERSECTIONS {
    tag "$meta.id"
    label 'process_low'
    
    container 'quay.io/biocontainers/coreutils:9.5'
    
    publishDir "${params.outdir}/counts", mode: 'copy'
    
    input:
    tuple val(meta), path(intersections_bed)
    
    output:
    tuple val(meta), path("${meta.id}.asisi_counts.tsv"), emit: counts
    path "versions.yml"                                 , emit: versions
    
    script:
    """
    #!/bin/bash
    
    # Create header
    echo -e "chrom\\tstart\\tend\\tcount" > ${meta.id}.asisi_counts.tsv
    
    # Count intersections per AsiSI site
    if [ -s ${intersections_bed} ]; then
        cut -f1-3,7 ${intersections_bed} | \\
        sort -k1,1 -k2,2n -k3,3n | \\
        awk '{
            key = \$1"\\t"\$2"\\t"\$3
            count[key] += \$4
        } 
        END {
            for (site in count) {
                print site"\\t"count[site]
            }
        }' | \\
        sort -k1,1 -k2,2n >> ${meta.id}.asisi_counts.tsv
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: \$(echo \$(sort --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
    END_VERSIONS
    """
}
