/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INDUCE-seq Analysis Workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INCLUDE MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MERGE_BREAKENDS      } from '../modules/merge_breakends'
include { BEDTOOLS_INTERSECT   } from '../modules/bedtools_intersect'
include { COUNT_INTERSECTIONS  } from '../modules/count_intersections'
include { COLLATE_STATISTICS   } from '../modules/collate_statistics'
include { COLLECT_STATISTICS   } from '../modules/collect_statistics'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    WORKFLOW: INDUCE-seq Analysis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow INDUCESEQ_ANALYSIS {

    main:

    ch_versions = Channel.empty()

    // Create input channel for sample files
    sample_ch = Channel
        .fromPath(params.sample_beds)
        .map { file ->
            def sample_id = file.getBaseName().tokenize('.')[0]
            def meta = [id: sample_id, file_type: 'bed']
            return [meta, file]
        }

    // Create value channel for AsiSI sites
    asisi_sites_ch = Channel.value(file(params.asisi_sites))

    // Execute workflow processes
    MERGE_BREAKENDS(sample_ch)
    ch_versions = ch_versions.mix(MERGE_BREAKENDS.out.versions)
    
    BEDTOOLS_INTERSECT(
        asisi_sites_ch,
        MERGE_BREAKENDS.out.merged_breakends
    )
    ch_versions = ch_versions.mix(BEDTOOLS_INTERSECT.out.versions)
    
    COUNT_INTERSECTIONS(BEDTOOLS_INTERSECT.out.intersections)
    ch_versions = ch_versions.mix(COUNT_INTERSECTIONS.out.versions)
    
    COLLATE_STATISTICS(
        COUNT_INTERSECTIONS.out.counts,
        MERGE_BREAKENDS.out.merged_breakends
    )
    ch_versions = ch_versions.mix(COLLATE_STATISTICS.out.versions)
    
    // Collect all statistics files
    all_stats = COLLATE_STATISTICS.out.statistics.map { _meta, file -> file }.collect()
    
    COLLECT_STATISTICS(all_stats)
    ch_versions = ch_versions.mix(COLLECT_STATISTICS.out.versions)

    emit:
    versions = ch_versions                 // channel: [ path(versions.yml) ]
}
