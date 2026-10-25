# Fill out your Project Information

Student1: Dingling Yang

Student2: Paula París Bayarri

Project Github url: https://github.com/paula2701/projectrnaseq


# Next steps

1. Add us to the Project Github
2. Work together on the pipeline
3. Commit+push your work frequently
4. Write your report and also upload your paper **in PDF format**


# Introduction to the project:
We build a small RNA-seq pipeline using the nf-core template, it takes FASTQ files as input and produce 
TPM table as output. 

# The pipeline includes 5 steps:
1. Quality control, with FastQC and MultiQC
2. Trimming, with fastp
3. Alignment, with HISAT2
4. Duplicate marking, with SAMtools
5. Gene counts and TPM, with featureCounts and a local TPM script

# And 2 extras:
1. Strandedness check, with RSeQC
2. Efficiency check of featureCounts, with Salmon

# Test it
For a test run of the pipeline with our example sample and reference, use the following command:
nextflow run . -profile test,docker --outdir results_test --quantifier featurecounts
