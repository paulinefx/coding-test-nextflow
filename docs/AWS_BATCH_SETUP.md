# AWS Batch Configuration Guide

## Prerequisites for AWS Batch

Before using the `aws` profile, you need to set up:

### 1. AWS Batch Infrastructure
- **Compute Environment**: EC2 or Fargate compute environment
- **Job Queue**: Connected to your compute environment  
- **Job Definition**: (Optional - Nextflow can create dynamically)

### 2. IAM Roles and Permissions
- **Batch Service Role**: `AWSBatchServiceRole`
- **Instance Role**: `ecsInstanceRole` 
- **Task Execution Role**: `ecsTaskExecutionRole`
- **User/Role Permissions**: Access to Batch, S3, ECR, CloudWatch

### 3. S3 Bucket
- Bucket for Nextflow work directory
- Proper read/write permissions

### 4. Network Configuration
- VPC with subnets (public for Fargate, private with NAT for EC2)
- Security groups allowing container communication

## Configuration Examples

### Basic AWS Batch Profile
```groovy
aws {
    process.executor = 'awsbatch'
    process.queue = 'your-job-queue-name'
    workDir = 's3://your-bucket/nextflow-work'
    aws.region = 'us-east-1'
    
    process {
        memory = '2 GB'
        cpus = 1
    }
}
```

### Advanced AWS Batch Profile
```groovy
aws {
    process.executor = 'awsbatch'
    process.queue = 'high-priority-queue'
    workDir = 's3://my-nextflow-bucket/work'
    
    aws {
        region = 'us-west-2'
        batch {
            cliPath = '/usr/local/bin/aws'
            maxParallelTransfers = 4
            maxTransferAttempts = 3
            delayBetweenAttempts = '5 sec'
        }
    }
    
    process {
        memory = { 2.GB * task.attempt }
        cpus = 1
        time = '2h'
        
        errorStrategy = 'retry'
        maxRetries = 3
        
        // Process-specific resources
        withName: 'MERGE_BREAKENDS|BEDTOOLS_INTERSECT' {
            memory = '4 GB'
            cpus = 2
        }
        
        withName: 'COLLECT_STATISTICS' {
            memory = '1 GB'
            cpus = 1
        }
    }
}
```

## Usage

### Method 1: Profile
```bash
nextflow run main.nf -profile aws \\
    --asisi_sites s3://your-bucket/data/chr21_AsiSI_sites.t2t.bed \\
    --sample_beds 's3://your-bucket/data/breaks/*.breakends.bed' \\
    --outdir s3://your-bucket/results
```

### Method 2: Command Line
```bash
nextflow run main.nf \\
    -process.executor awsbatch \\
    -process.queue my-job-queue \\
    -work-dir s3://my-bucket/work \\
    --outdir s3://my-bucket/results
```

## Troubleshooting

### Common Issues:
1. **Job Queue doesn't exist**: Verify queue name and region
2. **S3 permissions**: Ensure IAM roles have S3 access
3. **Container registry**: Ensure ECR/Docker Hub access
4. **Resource limits**: Check compute environment limits
5. **Network connectivity**: Verify VPC/subnet configuration

### Testing the Configuration:
```bash
# Test with a simple command first
nextflow run hello -profile aws

# Then test your pipeline with minimal data
nextflow run main.nf -profile aws,test
```
