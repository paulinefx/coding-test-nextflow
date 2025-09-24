#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INDUCE-seq Break Analysis Pipeline
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { validateParameters } from 'plugin/nf-schema'
include { INDUCESEQ_ANALYSIS } from './workflows/induceseq_analysis'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:

    // Validate input parameters
    validateParameters()

    // Print help message if requested
    if (params.help) {
        log.info """
        Usage:
        nextflow run ${workflow.manifest.name} [options]

        Required parameters:
        --asisi_sites         Path to the AsiSI sites BED file (default: data/chr21_AsiSI_sites.t2t.bed)
        --sample_beds         Glob pattern for sample BED files (default: data/breaks/*.breakends.bed)
        --outdir              Output directory (default: results)

        Optional parameters:
        --merge_distance      Distance for merging nearby break-ends [default: 0]
        --help                Show this help message

        Example:
        nextflow run ${workflow.manifest.name} \\
            --asisi_sites data/chr21_AsiSI_sites.t2t.bed \\
            --sample_beds 'data/breaks/*.breakends.bed' \\
            -profile docker
        """.stripIndent()
        System.exit(0)
    }

    // Print parameter summary log to screen
    log.info "Parameter Summary:"
    log.info "=================="
    log.info "AsiSI sites     : ${params.asisi_sites}"
    log.info "Sample BEDs     : ${params.sample_beds}"
    log.info "Merge distance  : ${params.merge_distance}"
    log.info "Output dir      : ${params.outdir}"
    log.info "=================="

    // Validate required files exist
    if (!file(params.asisi_sites).exists()) {
        error("AsiSI sites file not found: ${params.asisi_sites}")
    }

    def sample_files = file(params.sample_beds)
    if (sample_files.size() == 0) {
        error("No sample BED files found matching: ${params.sample_beds}")
    }

    log.info "Found ${sample_files.size()} sample files"

    // Run main analysis workflow
    INDUCESEQ_ANALYSIS()
}