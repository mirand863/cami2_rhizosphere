configfile: "config.yml"

workdir: config["workdir"]

rule all:
    input:
        ganon_build = ["results/ganon_build/refseq.filter"]

rule extract_files:
    input:
        taxdump = config["ncbi_taxonomy"],
        refseq = config["ncbi_refseq"]
    output:
        taxdump = "results/extracted_files/ncbi_taxonomy/taxdump.tar.gz",
        refseq = "results/extracted_files/refseq/refseq.fna.gz"
    params:
        base_output_folder = "results/extracted_files",
        refseq_output_folder = "results/extracted_files/refseq"
    shell:
        """
        tar -xf {input.taxdump} -C {params.base_output_folder}
        tar -xf {input.refseq} -C {params.refseq_output_folder}
        for f in {params.refseq_output_folder}/*.gz; do cat "$f" >> {output.refseq} && rm "$f"; done
        """

rule ganon_build:
    input:
        taxdump = "results/extracted_files/ncbi_taxonomy/taxdump.tar.gz",
        refseq = "results/extracted_files/refseq/refseq.fna.gz"
    output:
        "results/ganon_build/refseq.filter"
    params:
        prefix = "results/ganon_build/refseq",
        seq_info = "nucl_gb nucl_wgs dead_nucl dead_wgs"
    threads:
        config["threads"]
    resources:
        mem_mb = config["mem_mb"]
    log:
        std = "results/logs/ganon_build_std.txt",
        err = "results/logs/ganon_build_err.txt"
    conda:
        "envs/ganon.yml"
    benchmark:
        "results/benchmark/ganon_build.txt"
    shell:
        """
        ganon build --db-prefix {params.prefix} --input-files {input.refseq} --rank taxid --max-bloom-size {resources.mem_mb} --seq-info {params.seq_info} --taxdump-file {input.taxdump} --threads {threads} > log.std 2> log.err
        """
