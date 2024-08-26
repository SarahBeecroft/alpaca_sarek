# Sarek Nextflow Pipeline User Guide

## Introduction

This guide will help you run the [Sarek Nextflow](https://nf-co.re/sarek/3.4.3/) pipeline on Setonix. Sarek is a workflow designed for the analysis of germline and somatic WGS/WES data, but can be used for non-reference genomes too.

The Sarek version we have tested is 3.4.3. Different versions of Sarek may have different behaviours and issues. 

Setonix is a SLURM managed cluster at the Pawsey Supercomputing Research Centre. General information about using Setonix can be found [here](https://pawsey.atlassian.net/wiki/spaces/US/pages/51930840/Supercomputing+Documentation). 


## Installation and set-up of the pipeline. 
### This only needs to be done once (hopefully!)

1. Clone the Sarek repository in `$MYSOFTWARE`:
   ```bash
   cd $MYSOFTWARE
   git clone --branch 3.4.3 https://github.com/nf-core/sarek.git
   cd sarek
   ```
2.  Download our custom configuration file:
   ```bash
   wget https://raw.githubusercontent.com/SarahBeecroft/alpaca_sarek/main/setonix.config
   ```
3. Download and run the `fix_haplotypecaller.sh` file:
   ```bash
   wget https://raw.githubusercontent.com/SarahBeecroft/alpaca_sarek/main/fix_haplotypecaller.sh
   bash fix_haplotypecaller.sh
   rm fix_haplotypecaller.sh
   ```

## Preparing to run the pipeline 
- Ensure your input fastq files and reference genome files are on scratch
- Prepare your `samplesheet.csv` as per the example in this repo and the documentation from Sarek
- Prepare your slurm script with the correct parameters for your job
- Ensure that the singularity and nextflow module versions are up-to-date in your slurm script and setonix.config file. These change over time. 


## Running the Pipeline

Below is a template Slurm script to run the pipeline with our custom configuration:

```bash
#!/bin/bash -l
#SBATCH --account=$PAWSEY_PROJECT
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8GB
#SBATCH --partition=work
#SBATCH --time=24:00:00
#SBATCH --mail-user=you@email.com
#SBATCH --mail-type=ALL

module load pawseyenv/2023.08
module load nextflow/23.10.0 singularity/3.11.4-slurm

nextflow run main.nf \
	-profile singularity \
	-c setonix.config \
	-resume \
	--genome null \
	--igenomes_ignore \
	--fasta /path/to/reference.fasta \
	--fasta_fai /path/to/reference.fasta.fai \
	--input samplesheet.csv \
	--outdir $MYSCRATCH/path/to/output/directory \
	--save_reference \
	--tools haplotypecaller manta tiddit cnvkit \
	--skip_tools baserecalibrator \
	--aligner bwa-mem2 \
	--joint_germline TRUE
```
For the #SBATCH Slurm parameters, 2 CPUs and 8GB of mem should be more than enough to run the Nextflow master job. If you input your email address, you will get email updates about the job starting and ending. 

Replace /path/to/xxx with the path to your various input files, and your desired output directory. You can also adjust various other parameters according to the Sarek documentation. 

Once you are running the pipeline, you can watch the job queue with the following command if you are interested. Press `ctrl + c` to exit.
```bash
watch squeue -u $USER
```

## Custom Modifications
We've made some custom modifications to optimize the pipeline for our environment:
- Important custom configuration for Setonix via the setonix.config file
	- Enables jobs being submitted to the Slurm queue
 	- Sets limit for number of concurrent jobs to submit to the Slurm queue
  	- Enables Singularity and loads the Singularity module, which is current as of August 2024
  	- Sets higher than standard memory allocation for the BWAMEM2_INDEX, FASTQC, and BWAMEM1_MEM|BWAMEM2_MEM steps 
- Bug fix in `/subworkflows/local/bam_variant_calling_germline_all/main.nf` file
	- There is a known bug in Sarek 3.4.3, outlined [here](https://github.com/nf-core/sarek/issues/1550)
 	- The `fix_haplotypecaller.sh` script patches the file outlined above with the fix from the GitHub issue by modifying lines 133 and 134.

## Troubleshooting
If you encounter any issues, please check the following:

- Ensure all paths in your samplesheet are correct and accessible.
- Verify that the Slurm environment is properly set up.
- Check the Nextflow log files for any error messages (.nextflow.log)
- Check that the input fastq files are valid and formatted correctly
