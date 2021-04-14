# AdmixArray_snakemake

Create a set of mixtures of healthy/tumor BAMs with specific coverage / TF

This repository contains all the relevant files and demonstrates the folder structure to run a snakemake workflow that will prepare and merge a pair of healthy and tumor BAM files to produce an admixture with a specific coverage and tumor fraction. The workflow extracts chromosomal DNA, removes duplicates and creates metrics files for both the healthy and tumor samples. It then employs a Perl script to create the downsampling probabilities (or not if a solution cannot be found) for those prepared BAMs. After downsampling them, it merges them together to create four files: the merged *.bam file, the *.bai index file, a *.bam.bai symlink file and a *.metrics file.

To use this snakemake workflow...

Download all the relevant files and ensure the folder structure is intact for config, results, logs, and temp
Edit the config.yaml and samples.yaml files to ensure that the file paths are correct
Ensure that all relevant software packages are loaded / module loaded as needed
Use the dryrun.sh script to test the mixing.snakefile and find any errors
Use the runsnake.sh script to run the mixing.snakefile and launch jobs to the cluster
(Remove the placeholder.txt files if desired, leaving them in place does not affect the process)
In addition, all relevant files have been fully commented to assist in troubleshooting / changing parameters. In particular, look in the calcProbabilities.pl file for details on the calculation as well as the calcProbs.txt file produced by the process. Note that if the requested coverage / tumor fraction is not possible with these sample files, the process will halt at the creation of the calcProbs.txt file and that file will have information inside it identifying the issue, e.g. insufficient tumor reads, etc.
