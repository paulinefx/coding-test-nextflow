#!/bin/bash

# INDUCE-seq Analysis Pipeline Runner
# This script provides examples of how to run the pipeline with different configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE_DIR="$SCRIPT_DIR"

echo "=========================================="
echo "INDUCE-seq Break Analysis Pipeline Runner"
echo "=========================================="

# Function to print usage
usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  local     Run pipeline locally (default)"
    echo "  docker    Run pipeline with Docker"
    echo "  test      Run pipeline with test data"
    echo "  help      Show pipeline help"
    echo "  validate  Validate input files"
    echo ""
    echo "Examples:"
    echo "  $0 local"
    echo "  $0 docker"
    echo "  $0 test"
}

# Function to validate inputs
validate_inputs() {
    echo "Validating input files..."
    
    ASISI_FILE="${PIPELINE_DIR}/data/chr21_AsiSI_sites.t2t.bed"
    SAMPLE_DIR="${PIPELINE_DIR}/data/breaks"
    
    if [[ ! -f "$ASISI_FILE" ]]; then
        echo "ERROR: AsiSI sites file not found: $ASISI_FILE"
        exit 1
    fi
    
    if [[ ! -d "$SAMPLE_DIR" ]]; then
        echo "ERROR: Sample directory not found: $SAMPLE_DIR"
        exit 1
    fi
    
    SAMPLE_COUNT=$(find "$SAMPLE_DIR" -name "*.breakends.bed" | wc -l)
    if [[ $SAMPLE_COUNT -eq 0 ]]; then
        echo "ERROR: No sample BED files found in $SAMPLE_DIR"
        exit 1
    fi
    
    echo "✓ AsiSI sites file: $ASISI_FILE"
    echo "✓ Sample files: $SAMPLE_COUNT found in $SAMPLE_DIR"
    echo "Validation complete!"
}

# Function to run pipeline locally
run_local() {
    echo "Running pipeline locally..."
    validate_inputs
    
    cd "$PIPELINE_DIR"
    nextflow run main.nf \\
        -profile local \\
        --asisi_sites data/chr21_AsiSI_sites.t2t.bed \\
        --sample_beds "data/breaks/*.breakends.bed" \\
        --outdir results \\
        -with-report results/execution_report.html \\
        -with-trace results/execution_trace.txt \\
        -with-timeline results/execution_timeline.html \\
        -with-dag results/pipeline_dag.svg
}

# Function to run pipeline with Docker
run_docker() {
    echo "Running pipeline with Docker..."
    validate_inputs
    
    cd "$PIPELINE_DIR"
    nextflow run main.nf \\
        -profile docker \\
        --asisi_sites data/chr21_AsiSI_sites.t2t.bed \\
        --sample_beds "data/breaks/*.breakends.bed" \\
        --outdir results \\
        -with-report results/execution_report.html \\
        -with-trace results/execution_trace.txt
}

# Function to run pipeline with test data
run_test() {
    echo "Running pipeline with test data..."
    
    cd "$PIPELINE_DIR"
    nextflow run main.nf \\
        -profile test \\
        --outdir test_results \\
        -with-report test_results/execution_report.html \\
        -with-trace test_results/execution_trace.txt
}

# Function to show pipeline help
show_help() {
    cd "$PIPELINE_DIR"
    nextflow run main.nf --help
}

# Main execution logic
case "${1:-local}" in
    local)
        run_local
        ;;
    docker)
        run_docker
        ;;
    test)
        run_test
        ;;
    help)
        show_help
        ;;
    validate)
        validate_inputs
        ;;
    *)
        echo "ERROR: Unknown option '$1'"
        usage
        exit 1
        ;;
esac

echo ""
echo "Pipeline execution completed!"
echo "Check the results directory for outputs."
