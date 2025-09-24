# Project Setup Summary

## 📁 Project Structure

```
coding-test-nextflow/
├── main.nf                     # Main pipeline workflow (DSL2)
├── nextflow.config             # Main configuration file with nf-schema plugin
├── nextflow_schema.json        # JSON schema for parameter validation
├── nextflow_advanced.config    # Advanced configuration options
├── modules/                    # DSL2 process modules
│   ├── merge_breakends.nf      # Merge adjacent break sites
│   ├── bedtools_intersect.nf   # Intersect with AsiSI sites
│   ├── count_intersections.nf  # Count breaks per AsiSI site
│   ├── collate_statistics.nf   # Generate per-sample stats
│   └── collect_statistics.nf   # Combine all sample stats
├── lib/                        # Helper utilities
│   └── WorkflowUtils.groovy    # Utility functions
├── data/                       # Input data (provided)
│   ├── chr21_AsiSI_sites.t2t.bed
│   └── breaks/
│       ├── Sample1.breakends.bed
│       └── ... (16 samples total)
├── run_pipeline.sh             # Pipeline runner script
├── test_pipeline.sh            # Testing script
├── test_schema.sh              # nf-schema validation testing
├── README_PIPELINE.md          # Complete pipeline documentation
├── CHANGELOG.md                # Version history
├── LICENSE                     # MIT License
├── VERSION                     # Version number (1.0.0)
└── .gitignore                  # Git ignore file
```

## 🚀 Quick Start

### 1. Basic Usage
```bash
# Run with default settings
nextflow run main.nf

# Or use the helper script
./run_pipeline.sh local
```

### 2. Docker Usage
```bash
nextflow run main.nf -profile docker
# Or
./run_pipeline.sh docker
```

### 3. Test Run
```bash
nextflow run main.nf -profile test
# Or
./run_pipeline.sh test
```

### 4. Custom Parameters
```bash
nextflow run main.nf \\
    --asisi_sites data/chr21_AsiSI_sites.t2t.bed \\
    --sample_beds "data/breaks/*.breakends.bed" \\
    --merge_distance 10 \\
    --outdir custom_results
```

## 🔧 Parameter Validation with nf-schema@2.2.1

The pipeline now includes robust parameter validation using the nf-schema@2.2.1 plugin:

### Validation Features
```bash
# Show help with custom help message
nextflow run main.nf --help

# Validate parameters without running (preview mode)
nextflow run main.nf -preview --asisi_sites data/chr21_AsiSI_sites.t2t.bed

# Test parameter validation
./test_schema.sh

# Show hidden parameters (nf-schema@2.2.1 style)
nextflow run main.nf --showHidden --help
```

### Schema Features
✅ **JSON Schema 2020-12** - Latest schema specification  
✅ **File existence checks** - Input files verified before execution  
✅ **Type enforcement** - String, integer, boolean types enforced  
✅ **Range validation** - Numeric parameters checked against limits (merge_distance ≥ 0)  
✅ **Pattern matching** - File paths validated against expected patterns (.bed files)  
✅ **Custom help** - Clear usage examples and parameter descriptions  
✅ **Error messages** - Detailed validation error reporting  

### Example Validation Errors
```bash
# Invalid merge_distance
nextflow run main.nf --merge_distance -1
# ERROR: -1 is less than 0

# Invalid file path  
nextflow run main.nf --asisi_sites invalid_file.bed
# ERROR: the file or directory 'invalid_file.bed' does not exist
```

## 🔧 Configuration Profiles

- **local**: Run locally (default)
- **docker**: Run with Docker containers
- **slurm**: Run on SLURM cluster
- **aws**: Run on AWS Batch
- **test**: Run with subset of data for testing

## 📊 Pipeline Workflow

1. **MERGE_BREAKENDS**: Merge adjacent break sites using bedtools merge
2. **BEDTOOLS_INTERSECT**: Find overlaps between breaks and AsiSI sites
3. **COUNT_INTERSECTIONS**: Quantify breaks at each AsiSI site
4. **COLLATE_STATISTICS**: Generate per-sample summary statistics
5. **COLLECT_STATISTICS**: Combine all statistics into final table

## 📈 Outputs

```
results/
├── merged/                     # Per-sample merged BED files
├── intersections/              # Per-sample intersection results
├── counts/                     # Per-sample AsiSI site counts
├── statistics/                 # Per-sample statistics
└── all_samples_statistics.tsv  # Combined statistics
```

## 🧪 Testing

```bash
# Validate inputs
./run_pipeline.sh validate

# Run test suite
./test_pipeline.sh

# Test with subset
nextflow run main.nf -profile test
```

## 🌐 Cloud/HPC Examples

### SLURM Configuration
```groovy
slurm {
    process.executor = 'slurm'
    process.queue = 'normal'
    process.clusterOptions = '--account=your_account'
}
```

### AWS Batch Configuration
```groovy
aws {
    process.executor = 'awsbatch'
    process.queue = 'nextflow-queue'
    workDir = 's3://your-bucket/work'
}
```

## 📋 Requirements

- Nextflow >=22.10.1
- Singularity or Docker
- Input data in correct format

## 🐳 Container Dependencies

- **bedtools**: `quay.io/biocontainers/bedtools:2.31.1--hf5e1c6e_1`
- **coreutils**: `quay.io/biocontainers/coreutils:9.5`

## 📝 Key Features

✅ **DSL2 modular architecture**  
✅ **Container support for reproducibility**  
✅ **Multi-executor support (local, cluster, cloud)**  
✅ **nf-schema@2.2.1 parameter validation**  
✅ **JSON Schema 2020-12 specification**  
✅ **Auto-generated help documentation**  
✅ **Detailed execution reporting**  
✅ **Flexible configuration profiles**  
✅ **Automated testing framework**  
✅ **Complete documentation**  

## 🔄 Version Control

- Initial version: 1.0.0
- Git repository ready for version control
- Comprehensive .gitignore configuration

The Nextflow project is now fully set up and ready for use! 🎉
