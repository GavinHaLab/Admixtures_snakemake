# AdmixArray_snakemake

Create a set of mixtures of healthy/tumor BAMs with specific coverage / TF

This repository contains all the relevant files and demonstrates the folder structure to run a snakemake workflow that will prepare and merge  pairs of healthy and tumor BAM files to produce an admixture with a specific coverage and a range of tumor fractions. The workflow extracts chromosomal DNA, removes duplicates and creates metrics files for both the healthy and tumor samples. It then employs a python script to create the downsampling probabilities (or not if a solution cannot be found) for those prepared BAMs and creates a new, expanded file called samples2.yaml. After downsampling the necessary files (and avoiding redundant downsampling), it merges them together to create four files: the merged *.bam file, the *.bai index file, a *.bam.bai symlink file and a *.metrics file.

To use this snakemake workflow...

Download all the relevant files and ensure the folder structure is intact for config, results, logs, and temp
Edit the config.yaml and samples1.yaml files to ensure that the file paths are correct
Ensure that all relevant software packages are loaded / module loaded as needed
Use the dryrun1.sh script to test the mixarray_p1.snakefile and find any errors
Use the runsnake.sh script to run the mixarray_p1.snakefile, makeSamples2.py, mixarray_p2.snakefile and mixarray_p3.snakefile (in that order) and launch jobs to the cluster
(Remove the placeholder.txt files if desired, leaving them in place does not affect the process)
In addition, all relevant files have been fully commented to assist in troubleshooting / changing parameters. In particular, look in the makeSamples2.py file for details on the calculation as well as the logs/samples2yaml.txt file produced by the process. Note that if the requested coverage / tumor fraction is not possible with these sample files, the process will have errors in the creation of the samples2.yaml file and the log file samples2yaml.txt will have information inside it identifying the issue, e.g. insufficient tumor reads, etc.
The samples1.yaml provided with this repo is an example in which we have 4 input samples, 3 mixtures and different ranges of tumor fractions.
