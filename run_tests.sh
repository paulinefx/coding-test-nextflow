#!/usr/bin/env bash

# INDUCE-seq Pipeline Test Suite
# This script runs all nf-test cases for the pipeline

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if nf-test is installed
check_nf_test() {
    if ! command -v nf-test &> /dev/null; then
        print_status $RED "❌ nf-test is not installed or not in PATH"
        print_status $YELLOW "📦 Please install nf-test: https://code.askimed.com/nf-test/installation/"
        print_status $YELLOW "💡 Quick install: curl -fsSL https://code.askimed.com/install/nf-test | bash"
        exit 1
    fi
    
    print_status $GREEN "✅ nf-test found: $(nf-test version 2>/dev/null | head -n1 || echo 'version check failed')"
}

# Function to check if Nextflow is installed
check_nextflow() {
    if ! command -v nextflow &> /dev/null; then
        print_status $RED "❌ Nextflow is not installed or not in PATH"
        print_status $YELLOW "📦 Please install Nextflow: https://www.nextflow.io/docs/latest/getstarted.html"
        exit 1
    fi
    
    print_status $GREEN "✅ Nextflow found: $(nextflow -version 2>/dev/null | head -n1 | grep -o 'version [0-9.]*' || echo 'version check failed')"
}

# Function to run tests
run_tests() {
    local test_type=$1
    local test_pattern=$2
    
    print_status $BLUE "🧪 Running ${test_type} tests..."
    
    if nf-test test --pattern "${test_pattern}" --verbose; then
        print_status $GREEN "✅ ${test_type} tests passed"
        return 0
    else
        print_status $RED "❌ ${test_type} tests failed"
        return 1
    fi
}

# Main execution
main() {
    print_status $BLUE "🚀 Starting INDUCE-seq Pipeline Test Suite"
    echo
    
    # Check prerequisites
    check_nextflow
    check_nf_test
    echo
    
    # Initialize nf-test if needed
    if [ ! -f ".nf-test/nf-test.config" ]; then
        print_status $YELLOW "⚙️  Initializing nf-test..."
        nf-test init
    fi
    
    local failed_tests=0
    
    # Run module tests
    if ! run_tests "Module" "tests/modules/**"; then
        ((failed_tests++))
    fi
    echo
    
    # Run workflow tests
    if ! run_tests "Workflow" "tests/workflows/**"; then
        ((failed_tests++))
    fi
    echo
    
    # Run all tests together for coverage
    print_status $BLUE "📊 Running all tests with coverage..."
    if nf-test test --coverage; then
        print_status $GREEN "✅ Full test suite completed successfully"
        
        # Show coverage report if available
        if [ -f ".nf-test/coverage/coverage.txt" ]; then
            print_status $BLUE "📋 Coverage Summary:"
            cat .nf-test/coverage/coverage.txt
        fi
    else
        print_status $RED "❌ Full test suite failed"
        ((failed_tests++))
    fi
    
    echo
    if [ $failed_tests -eq 0 ]; then
        print_status $GREEN "🎉 All tests passed successfully!"
        exit 0
    else
        print_status $RED "💥 ${failed_tests} test suite(s) failed"
        exit 1
    fi
}

# Help function
show_help() {
    echo "INDUCE-seq Pipeline Test Suite"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -m, --modules  Run only module tests"
    echo "  -w, --workflow Run only workflow tests"
    echo "  -c, --coverage Run tests with coverage reporting"
    echo "  -v, --verbose  Enable verbose output"
    echo
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 --modules          # Run only module tests"
    echo "  $0 --workflow         # Run only workflow tests"
    echo "  $0 --coverage         # Run all tests with coverage"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -m|--modules)
        check_nextflow
        check_nf_test
        run_tests "Module" "tests/modules/**"
        exit $?
        ;;
    -w|--workflow)
        check_nextflow
        check_nf_test
        run_tests "Workflow" "tests/workflows/**"
        exit $?
        ;;
    -c|--coverage)
        check_nextflow
        check_nf_test
        nf-test test --coverage
        exit $?
        ;;
    -v|--verbose)
        check_nextflow
        check_nf_test
        nf-test test --verbose
        exit $?
        ;;
    "")
        main
        ;;
    *)
        print_status $RED "❌ Unknown option: $1"
        echo
        show_help
        exit 1
        ;;
esac
