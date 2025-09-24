# INDUCE-seq Break Analysis Pipeline

A Nextflow DSL2 pipeline for processing INDUCE-seq break-end bed files to quantify breaks at predicted AsiSI restriction enzyme sites and generate comprehensive summary statistics.

## Quick Start

1. Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.1`)
2. Install [Docker](https://docs.docker.com/engine/installation/) or [Singularity](https://www.sylabs.io/guides/3.0/user-guide/) for full pipeline reproducibility
3. Run the pipeline:

```bash
# Basic usage with Docker
nextflow run main.nf -profile docker

# Local execution (requires bedtools installed)  
nextflow run main.nf -profile local
```

## Pipeline Summary

This pipeline processes INDUCE-seq break-end BED files through a comprehensive 5-step analysis:

1. **MERGE_BREAKENDS**: Merge adjacent break sites using `bedtools merge -d 0 -c 4 -o count`
2. **BEDTOOLS_INTERSECT**: Find overlaps between breaks and predicted AsiSI cut sites
3. **COUNT_INTERSECTIONS**: Quantify break counts per AsiSI site (chrom, start, end)
4. **COLLATE_STATISTICS**: Calculate per-sample metrics (unique sites, mean breaks, etc.)
5. **COLLECT_STATISTICS**: Combine all sample statistics into final summary table

### Key Features
- ✅ **Modular DSL2 architecture** with separate workflow and process modules
- ✅ **Comprehensive testing** with nf-test framework (13 test cases)
- ✅ **Multi-executor support** (local, SLURM, AWS Batch)
- ✅ **Containerized execution** for full reproducibility
- ✅ **Parameter validation** with nf-schema plugin
- ✅ **CI/CD integration** with GitHub Actions

## Parameter Validation

This pipeline uses the [nf-schema@2.2.1](https://nextflow-io.github.io/nf-schema/) plugin for robust parameter validation:

- **JSON Schema validation**: All parameters are validated against a JSON schema
- **File existence checks**: Input files are verified to exist before pipeline execution
- **Type checking**: Parameter types (strings, integers, booleans) are enforced
- **Range validation**: Numeric parameters are checked against allowed ranges
- **Pattern matching**: File paths are validated against expected patterns

### Validation Features

✅ **Automatic validation** on pipeline start  
✅ **Detailed error messages** for invalid parameters  
✅ **Custom help text** with usage examples  
✅ **Parameter summaries** with validation status  
✅ **JSON Schema 2020-12** support  

### Validation Examples

```bash
# This will fail with validation error
nextflow run main.nf --merge_distance -1
# ERROR: -1 is less than 0

# This will fail with file not found error  
nextflow run main.nf --asisi_sites invalid_file.bed
# ERROR: the file or directory 'invalid_file.bed' does not exist

# This will pass validation
nextflow run main.nf --merge_distance 5 --outdir custom_results
```

## Input Files

- **AsiSI sites BED**: `data/chr21_AsiSI_sites.t2t.bed`
- **Sample break-end BEDs**: `data/breaks/*.breakends.bed` (16 samples)

## Parameters

### Required
- `--asisi_sites`: Path to the AsiSI sites BED file (default: `data/chr21_AsiSI_sites.t2t.bed`)
- `--sample_beds`: Glob pattern for sample BED files (default: `data/breaks/*.breakends.bed`)
- `--outdir`: Output directory (default: `results`)

### Optional
- `--merge_distance`: Distance for merging nearby break-ends (default: `0`)
- `--help`: Show usage and exit

## Usage

### Show help and parameter information
```bash
nextflow run main.nf --help
```

### Basic usage
```bash
nextflow run main.nf
```

### Custom parameters with validation
```bash
nextflow run main.nf \\
    --asisi_sites path/to/asisi_sites.bed \\
    --sample_beds "path/to/samples/*.bed" \\
    --merge_distance 10 \\
    --outdir my_results
```

### Parameter validation testing
```bash
# Test parameter validation
./test_schema.sh

# Validate parameters without running
nextflow run main.nf -preview \\
    --asisi_sites data/chr21_AsiSI_sites.t2t.bed \\
    --sample_beds "data/breaks/*.breakends.bed"
```

## Execution Profiles

### Local execution (default)
```bash
nextflow run main.nf -profile local
```

### Docker
```bash
nextflow run main.nf -profile docker
```

### SLURM cluster
```bash
nextflow run main.nf -profile slurm
```

### AWS Batch
```bash
nextflow run main.nf -profile aws
```

### Test profile (subset of data)
```bash
nextflow run main.nf -profile test
```

### Combined Profiles

Profiles can be combined using comma separation to leverage multiple configurations:

#### AWS Batch with Docker
```bash
# Use AWS Batch executor with Docker containers
nextflow run main.nf -profile aws,docker \
    --asisi_sites s3://your-bucket/data/chr21_AsiSI_sites.t2t.bed \
    --sample_beds 's3://your-bucket/data/breaks/*.breakends.bed' \
    --outdir s3://your-bucket/results
```

#### AWS Batch with Singularity  
```bash
# Use AWS Batch executor with Singularity containers
nextflow run main.nf -profile aws,singularity \
    --asisi_sites s3://your-bucket/data/chr21_AsiSI_sites.t2t.bed \
    --sample_beds 's3://your-bucket/data/breaks/*.breakends.bed' \
    --outdir s3://your-bucket/results
```

#### SLURM with Docker
```bash
# Use SLURM executor with Docker containers
nextflow run main.nf -profile slurm,docker
```

#### Test with Docker
```bash
# Test with minimal data using Docker containers
nextflow run main.nf -profile test,docker
```

**Note**: Profile order matters - later profiles can override settings from earlier ones. Container engine profiles (docker/singularity) typically work well with executor profiles (aws/slurm).

## Cloud/HPC Configuration Examples

### SLURM Configuration
To run on a SLURM cluster, modify the `slurm` profile in `nextflow.config`:

```groovy
slurm {
    process.executor = 'slurm'
    process.queue = 'your_queue_name'
    process.clusterOptions = '--account=your_account --partition=your_partition'
    process.module = ['Nextflow', 'Singularity']
}
```

### AWS Batch Configuration

⚠️ **Prerequisites**: AWS Batch requires pre-configured infrastructure (compute environment, job queue, IAM roles, S3 bucket). See [docs/AWS_BATCH_SETUP.md](docs/AWS_BATCH_SETUP.md) for detailed setup instructions.

```groovy
aws {
    // AWS Batch executor configuration
    process.executor = 'awsbatch'
    process.queue = 'default'  // Set to your AWS Batch job queue
    workDir = 's3://your-bucket/nextflow-work'  // Set to your S3 bucket
    
    // AWS region and credentials (can also be set via AWS CLI/IAM roles)
    aws.region = 'us-east-1'
    aws.batch.cliPath = '/usr/local/bin/aws'
    
    // Process resource defaults for AWS Batch
    process {
        memory = '2 GB'
        cpus = 1
        time = '1h'
        
        // Override for specific processes if needed
        withName: 'MERGE_BREAKENDS|BEDTOOLS_INTERSECT' {
            memory = '4 GB'
            cpus = 2
        }
    }
    
    // Use existing containers from process definitions
    docker.enabled = true
}
```

#### Quick AWS Batch Usage
```bash
# Set up your AWS credentials first
export AWS_PROFILE=your-profile
# or
aws configure

# Run with AWS Batch (ensure S3 paths for data)
nextflow run main.nf -profile aws \
    --asisi_sites s3://your-bucket/data/chr21_AsiSI_sites.t2t.bed \
    --sample_beds 's3://your-bucket/data/breaks/*.breakends.bed' \
    --outdir s3://your-bucket/results
```

## Testing

This pipeline includes comprehensive testing with the nf-test framework:

### Quick Test Execution
```bash
# Run all tests
./run_tests.sh

# Run specific test types  
./run_tests.sh --modules     # Module unit tests
./run_tests.sh --workflow    # Integration tests
./run_tests.sh --coverage    # With coverage reporting

# Manual testing (alternative to nf-test)
./tests/manual_test.sh
```

### Test Coverage
- **13 comprehensive test cases** across 5 modules
- **Unit tests** for each process module
- **Integration tests** for complete workflow
- **CI/CD automation** via GitHub Actions
- **Cross-platform testing** (Linux, macOS compatibility)

For detailed testing information, see [docs/TESTING.md](docs/TESTING.md).

## Output Structure

```
results/
├── merged/                     # Per-sample merged BED files
│   ├── Sample1.merged.bed
│   └── Sample2.merged.bed...
├── intersections/              # Per-sample intersection results  
│   ├── Sample1.intersections.bed
│   └── Sample2.intersections.bed...
├── counts/                     # Per-sample AsiSI site counts
│   ├── Sample1.asisi_counts.tsv
│   └── Sample2.asisi_counts.tsv...
├── statistics/                 # Per-sample statistics
│   ├── Sample1.statistics.tsv
│   └── Sample2.statistics.tsv...
└── all_samples_statistics.tsv  # Combined statistics for all samples
```

### Output File Details

- **Per-sample merged BED**: `{sample_id}.merged.bed`
  - Format: `chr start end count` (bedtools merge output with count column)
- **Per-sample intersections**: `{sample_id}.intersections.bed`
  - Format: overlapping regions between breaks and AsiSI sites
- **Per-sample counts**: `{sample_id}.asisi_counts.tsv`
  - Format: tab-separated counts per AsiSI site
- **Per-sample statistics**: `{sample_id}.statistics.tsv`
  - Columns: `sample`, `unique_asisi_sites`, `mean_breaks_per_asisi`, `mean_merged_breakends`
- **Combined statistics**: `all_samples_statistics.tsv`
  - All sample statistics concatenated and sorted by sample name

## Pipeline Architecture

The pipeline follows modern Nextflow DSL2 best practices:

### Project Structure
```
├── main.nf                     # Entry point with parameter validation
├── workflows/
│   └── induceseq_analysis.nf   # Main analysis workflow
├── modules/                    # Process definitions (5 modules)
│   ├── merge_breakends.nf
│   ├── bedtools_intersect.nf
│   ├── count_intersections.nf
│   ├── collate_statistics.nf
│   └── collect_statistics.nf
├── tests/                      # Comprehensive test suite
│   ├── modules/                # Unit tests (5 test files)
│   ├── workflows/              # Integration tests  
│   └── data/                   # Test datasets
├── docs/                       # Documentation
└── .github/workflows/          # CI/CD automation
```

### Design Principles
- ✅ **Separation of concerns**: Entry point, workflow, and processes clearly separated
- ✅ **Modular architecture**: Each process in dedicated module file
- ✅ **Reusable workflows**: `INDUCESEQ_ANALYSIS` workflow can be imported by other pipelines
- ✅ **Container-first**: All processes use biocontainers for reproducibility
- ✅ **Multi-executor**: Supports local, HPC (SLURM), and cloud (AWS Batch) execution
- ✅ **Robust validation**: Parameter checking with nf-schema plugin
- ✅ **Comprehensive testing**: Unit and integration tests with nf-test framework
- ✅ **Production-ready**: CI/CD, documentation, and error handling

## Requirements

- Nextflow >=22.10.1
- Singularity or Docker
- Container runtime environment

## Software Dependencies

All software dependencies are managed through biocontainers for maximum reproducibility:

- **bedtools v2.31.1**: `quay.io/biocontainers/bedtools:2.31.1--hf5e1c6e_1`
  - Used for: BED file merging, intersection operations
  - Processes: `MERGE_BREAKENDS`, `BEDTOOLS_INTERSECT`

- **coreutils v9.5**: `quay.io/biocontainers/coreutils:9.5`  
  - Used for: Text processing, counting, statistics calculation
  - Processes: `COUNT_INTERSECTIONS`, `COLLATE_STATISTICS`, `COLLECT_STATISTICS`

### Container Advantages
- ✅ **Reproducibility**: Exact software versions across environments
- ✅ **Portability**: Runs identically on local, HPC, and cloud systems
- ✅ **No installation**: No need to install dependencies manually
- ✅ **Version control**: Software versions tracked in pipeline code

## Troubleshooting

### Common Issues

**Container Problems**:
- On Apple Silicon (M1/M2): May see platform warnings (AMD64 vs ARM64) but should still work
- Solution: Use `--platform linux/amd64` in Docker settings or install tools natively

**Memory Issues**:
- Large datasets may require more memory allocation
- Solution: Adjust `process.memory` in profiles or use `--max_memory` parameter

**AWS Batch Setup**:  
- Requires extensive AWS infrastructure setup
- Solution: See detailed guide in [docs/AWS_BATCH_SETUP.md](docs/AWS_BATCH_SETUP.md)

### Getting Help

1. **Check logs**: Look at `.nextflow.log` for detailed error messages
2. **Test with subset**: Use `-profile test` for debugging with minimal data  
3. **Validate parameters**: Use `--help` to check parameter requirements
4. **Manual testing**: Use `./tests/manual_test.sh` for component validation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citation

If you use this pipeline in your research, please cite:

> **INDUCE-seq Break Analysis Pipeline**: A Nextflow DSL2 pipeline for quantifying DNA breaks at AsiSI restriction sites. 
> GitHub: https://github.com/your-org/induce-seq-analysis

## Contributing

Contributions are welcome! Please see our contributing guidelines and submit pull requests for any improvements.

## Acknowledgments

- **Nextflow team** for the excellent workflow framework
- **nf-core community** for DSL2 best practices and standards  
- **Biocontainers project** for providing containerized bioinformatics tools
- **INDUCE-seq technology** developers for the innovative DSB detection method
