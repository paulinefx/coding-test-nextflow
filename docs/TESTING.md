# Testing Guide - INDUCE-seq Analysis Pipeline

This document describes the comprehensive testing framework implemented for the INDUCE-seq analysis pipeline using nf-test.

## Overview

The testing framework includes:
- **Module Tests**: Unit tests for individual Nextflow processes
- **Workflow Tests**: Integration tests for the complete pipeline
- **Automated CI/CD**: GitHub Actions workflow for continuous testing
- **Coverage Reporting**: Code coverage analysis for test completeness

## Prerequisites

### Required Software
- **Nextflow** (≥22.10.1): Pipeline execution engine
- **nf-test** (≥0.8.0): Testing framework for Nextflow pipelines
- **Singularity** or **Docker**: Container runtime for reproducible testing

### Installation

#### Install nf-test
```bash
# Quick installation
curl -fsSL https://code.askimed.com/install/nf-test | bash

# Or manually download from GitHub releases
wget https://github.com/askimed/nf-test/releases/latest/download/nf-test
chmod +x nf-test
sudo mv nf-test /usr/local/bin/
```

#### Install Nextflow
```bash
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
```

## Test Structure

```
tests/
├── nextflow.config           # Test-specific configuration
├── data/                     # Test datasets
│   ├── test_chr21_AsiSI_sites.bed
│   └── test_breaks/
│       ├── TestSample1.breakends.bed
│       └── TestSample2.breakends.bed
├── modules/                  # Module unit tests
│   ├── merge_breakends.nf.test
│   ├── bedtools_intersect.nf.test
│   ├── count_intersections.nf.test
│   ├── collate_statistics.nf.test
│   └── collect_statistics.nf.test
└── workflows/                # Workflow integration tests
    └── main.nf.test
```

## Running Tests

### Quick Start
```bash
# Run all tests
./run_tests.sh

# Show help
./run_tests.sh --help
```

### Specific Test Types
```bash
# Module tests only
./run_tests.sh --modules

# Workflow tests only
./run_tests.sh --workflow

# Tests with coverage
./run_tests.sh --coverage

# Verbose output
./run_tests.sh --verbose
```

### Direct nf-test Commands
```bash
# Initialize nf-test (first time only)
nf-test init

# Run all tests
nf-test test

# Run specific test file
nf-test test tests/modules/merge_breakends.nf.test

# Run tests with coverage
nf-test test --coverage

# Run tests with specific tags
nf-test test --tag modules
nf-test test --tag integration
```

## Test Data

### Test Datasets
The pipeline includes minimal test datasets that validate core functionality:

- **AsiSI sites**: 3 test regions on chr21
- **Breakend files**: 2 sample files with overlapping breaks
- **Expected outputs**: Known intersection counts for validation

### Test Data Characteristics
- **Small size**: Fast execution for CI/CD
- **Representative**: Covers main analysis scenarios
- **Deterministic**: Consistent results across runs
- **Edge cases**: Empty files, single samples, no intersections

## Module Tests

Each process module has comprehensive unit tests:

### MERGE_BREAKENDS
- Tests merging multiple breakend files
- Validates single file handling
- Checks output format and content

### BEDTOOLS_INTERSECT
- Tests intersection finding between breakends and AsiSI sites
- Validates handling of no intersections
- Checks proper bedtools output format

### COUNT_INTERSECTIONS
- Tests accurate counting of intersections
- Validates empty file handling
- Checks count file format

### COLLATE_STATISTICS
- Tests collation of multiple count files
- Validates single file processing
- Checks statistical summary format

### COLLECT_STATISTICS
- Tests final report generation
- Validates summary statistics calculation
- Checks report completeness

## Workflow Tests

Integration tests validate end-to-end pipeline functionality:

### Success Scenarios
- Complete workflow execution with test data
- Proper output file generation
- Correct result format validation

### Failure Scenarios
- Invalid input file handling
- Missing file graceful failure
- Error propagation testing

## Coverage Reporting

The testing framework includes code coverage analysis:

```bash
# Generate coverage report
nf-test test --coverage

# View coverage results
cat .nf-test/coverage/coverage.txt
```

### Coverage Metrics
- **Process coverage**: Percentage of processes tested
- **Line coverage**: Percentage of code lines executed
- **Branch coverage**: Percentage of conditional branches tested

## Continuous Integration

### GitHub Actions Workflow
The pipeline includes automated testing via GitHub Actions:

- **Matrix testing**: Multiple Nextflow versions
- **Container support**: Singularity-based testing
- **Coverage reporting**: Automatic coverage upload
- **Artifact collection**: Test result preservation

### CI Configuration
Location: `.github/workflows/nf-test.yml`

Triggers:
- Push to main/develop branches
- Pull requests to main branch

## Best Practices

### Writing Tests
1. **Descriptive names**: Clear test case descriptions
2. **Minimal data**: Small, focused test datasets
3. **Assertions**: Comprehensive output validation
4. **Edge cases**: Test boundary conditions
5. **Independence**: Tests should not depend on each other

### Test Organization
1. **Separation**: Keep module and workflow tests separate
2. **Grouping**: Use tags for test categorization
3. **Naming**: Consistent file naming conventions
4. **Documentation**: Comment complex test logic

### Performance
1. **Parallel execution**: Tests run in parallel when possible
2. **Resource limits**: Appropriate CPU/memory allocation
3. **Caching**: Container image caching for faster runs
4. **Cleanup**: Automatic test artifact cleanup

## Troubleshooting

### Common Issues

#### nf-test not found
```bash
# Check installation
which nf-test
nf-test version

# Reinstall if needed
curl -fsSL https://code.askimed.com/install/nf-test | bash
```

#### Container issues
```bash
# Check Singularity
singularity --version

# Check container pulling
singularity pull docker://biocontainers/bedtools:2.31.1--hf5e1c6e_2
```

#### Test failures
```bash
# Run with verbose output
nf-test test --verbose

# Check specific failing test
nf-test test tests/modules/failing_test.nf.test --verbose

# Check work directory for debugging
ls -la .nf-test/tests/*/work/
```

### Debug Tips
1. **Verbose mode**: Use `--verbose` for detailed output
2. **Work directory**: Check `.nf-test/tests/*/work/` for intermediate files
3. **Container logs**: Review container execution logs
4. **Resource monitoring**: Check CPU/memory usage during tests

## Integration with Development Workflow

### Pre-commit Testing
```bash
# Add to git pre-commit hook
#!/bin/bash
./run_tests.sh --modules
if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi
```

### Development Cycle
1. **Write code**: Implement new features
2. **Write tests**: Add corresponding test cases
3. **Run tests**: Validate functionality locally
4. **Commit changes**: Push to repository
5. **CI validation**: Automated testing in GitHub Actions

## Advanced Topics

### Custom Test Configuration
Modify `tests/nextflow.config` for specific test requirements:
- Resource allocation
- Container settings
- Parameter overrides

### Performance Testing
For performance validation:
```bash
# Time test execution
time nf-test test

# Monitor resource usage
nf-test test --profile test_profile
```

### Test Data Management
- Keep test data minimal but representative
- Version control test datasets
- Document expected outputs
- Automate test data generation when possible

## References

- [nf-test Documentation](https://code.askimed.com/nf-test/)
- [Nextflow Testing Best Practices](https://www.nextflow.io/docs/latest/developer/testing.html)
- [GitHub Actions for Nextflow](https://github.com/nf-core/setup-nextflow)
- [nf-core Testing Guidelines](https://nf-co.re/docs/contributing/tutorials/creating_with_template)
