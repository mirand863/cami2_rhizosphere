configfile: "config.yml"

workdir: config["workdir"]

rule all:
    input:
        sample_0 = ["data/rhizosphere/reads/rhimgCAMI2_short_read_sample_0_reads.fq.gz"],
        refseq = ["data/RefSeq_genomic_20190108.tar"]

rule download_cami_client:
    params:
        url = config["cami_client_url"]
    output:
        "results/bin/camiClient.jar"
    conda:
        "envs/cami_client.yml"
    shell:
        """
        wget -O {output} {params.url}
        """

rule download_rhizosphere:
    input:
        cami_client = "results/bin/camiClient.jar",
        linkfile = config["rhizosphere_linkfile"]
    output:
        sample_0 = config["samples"]["sample_0"]
    params:
        output_dir = "data/rhizosphere"
    conda:
        "envs/cami_client.yml"
    threads:
        config["threads"]
    shell:
        """
        java -jar {input.cami_client} --download {input.linkfile} {params.output_dir} --pattern short --retry --threads {threads}
        """

rule download_refseq:
    output:
        "data/RefSeq_genomic_20190108.tar"
    params:
        url = config["refseq_url"],
        dir = "data"
    conda:
        "envs/aria2.yml"
    shell:
        """
        aria2c --file-allocation=none --max-tries 0 -c -x 10 -s 10 -d {params.dir} {params.url}
        """
