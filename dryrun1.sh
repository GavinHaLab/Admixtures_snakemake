echo ""
echo "Running the snakemake workflow for the admixture process..."
/fh/fast/ha_g/app/bin/snakemake -s mixarray_p1.snakefile --latency-wait 60 --keep-going --cluster-config config/cluster_slurm.yaml --cluster "sbatch -p {cluster.partition} --mem={cluster.mem} -t {cluster.time} -c {cluster.ncpus} -n {cluster.ntasks} -o {cluster.output} --requeue" -j 40 -np
