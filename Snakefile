configfile: "config.yml"

workdir: config["workdir"]

rule all:
    input:
        sample_0 = ["data/rhizosphere/reads/rhimgCAMI2_short_read_sample_0_reads.fq.gz"]

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
