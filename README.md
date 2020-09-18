# Cami2 Rhizosphere
Repository containing instructions on how to run ganon with the CAMI2 rhizosphere dataset

# Installation
The first step to reproduce the results is to clone this repository:

`git clone https://github.com/mirand863/cami2_rhizosphere.git`

The dependencies are managed with conda, so you need to install Anaconda or Miniconda with python 3. For installation instructions, please visit https://www.anaconda.com/products/individual.

To install the other dependencies we will create and activate a conda environment called snakemake with the following commands:

```
cd cami2_rhizosphere
conda env create -f envs/snakemake.yml
conda activate snakemake
```

By default conda will fail to activate the environments in the pipeline, but that can be easily fixed if we copy the activate binary from the base environment to the one we just created. This can be done running the command:

```
cp ~/anaconda3/bin/activate ~/anaconda3/envs/snakemake/bin/
```

Please, replace the conda installation path accordingly.

Next we will run the command `pwd` and update the workdir in the file config.yml with its output.

# Download datasets

The only file required to download the datasets is the rhizosphere linkfile, which can be download from the cami 2 website. This linkfile should be saved in the path data/rhizosphere.linkfile. Alternatively, this path can be altered in the config.yml file. To download the datasets, please run:

`snakemake --use-conda --cores 112 -s download_datasets`

The parameter --use-conda tells snakemake to use conda to manage dependencies of the pipeline, while with the parameter --cores you can choose how many cpus can be used and the parameter -s selects the snakefile to be run.

# Running Ganon

To run ganon, simply execute the command:

`snakemake --use-conda --cores 112 -s run_ganon`

The binning output will be stored in the folder results/postprocessing. These files are already in the CAMI taxonomic binning output format.
