#!/bin/bash

# Manual testing script for INDUCE-seq pipeline
# This provides an alternative to nf-test for local verification

set -e

echo "🧪 Manual Testing Script for INDUCE-seq Pipeline"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_output="$3"
    
    echo -e "\n${YELLOW}Testing: $test_name${NC}"
    echo "Command: $test_command"
    
    if eval "$test_command"; then
        if [ -n "$expected_output" ] && [ -f "$expected_output" ]; then
            echo -e "${GREEN}✅ $test_name - PASSED${NC}"
            echo "Output preview:"
            head -3 "$expected_output" 2>/dev/null || echo "  (file exists but empty or unreadable)"
            ((TESTS_PASSED++))
        elif [ -z "$expected_output" ]; then
            echo -e "${GREEN}✅ $test_name - PASSED${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}❌ $test_name - FAILED (missing output: $expected_output)${NC}"
            ((TESTS_FAILED++))
        fi
    else
        echo -e "${RED}❌ $test_name - FAILED${NC}"
        ((TESTS_FAILED++))
    fi
}

# Create test output directory
mkdir -p tests/manual_output
cd tests/manual_output

echo -e "\n${YELLOW}Running manual tests...${NC}"

# Test 1: MERGE_BREAKENDS process
run_test "MERGE_BREAKENDS process" \
    "sort -k1,1 -k2,2n ../data/test_breaks/TestSample1.breakends.bed | bedtools merge -i stdin -d 0 -c 4 -o count > merge_test.bed" \
    "merge_test.bed"

# Test 2: BEDTOOLS_INTERSECT process
run_test "BEDTOOLS_INTERSECT process" \
    "bedtools intersect -a ../data/test_breaks/TestSample1.breakends.bed -b ../data/chr21_AsiSI_sites.test.bed -wa -wb > intersect_test.bed" \
    "intersect_test.bed"

# Test 3: COUNT_INTERSECTIONS process
run_test "COUNT_INTERSECTIONS process" \
    "wc -l < ../data/test_breaks/TestSample1.breakends.bed > count_test.txt" \
    "count_test.txt"

# Test 4: Pipeline dry-run
cd ../..
run_test "Pipeline dry-run" \
    "nextflow run main.nf -stub-run --asisi_sites_bed data/chr21_AsiSI_sites.t2t.bed --breakends_dir data/breaks --outdir test_results" \
    ""

# Test 5: Full pipeline with test data
run_test "Full pipeline with test data" \
    "nextflow run main.nf --asisi_sites_bed tests/data/chr21_AsiSI_sites.test.bed --breakends_dir tests/data/test_breaks --outdir test_results --max_memory 2.GB --max_cpus 1" \
    ""

# Summary
echo -e "\n${YELLOW}Test Summary${NC}"
echo "============"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed${NC}"
    exit 1
fi
