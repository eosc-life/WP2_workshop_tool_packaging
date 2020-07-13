# Example of the use of Conda packages for NGS sequence quality control

**Objective**: Learn how to use conda packages and some best practices through a simple NGS sequence analysis (sequence quality control)

**Requirements**: 
- Basic unix commands knowledge
- Python 3 installed

**Time estimation**: 20 minutes

**Table of content**:

- [Introduction](#introduction)
- [Set up the Conda environment](#set-up-the-conda-environment)
  * [Install Miniconda](#install-miniconda)
  * [Set up channels](#set-up-channels)
  * [Search for tool packages](#search-for-tool-packages)
  * [Create a conda environment](#create-a-conda-environment)
- [Run the sequence control quality in the Conda environment](#run-the-sequence-control-quality-in-the-conda-environment)
  * [Introduction to the fastq format](#introduction-to-the-fastq-format)
  * [Get the data](#get-the-data)
  * [Control quality with FastQC](#control-quality-with-fastqc)
  * [Filter and trim with Cutadapt](#filter-and-trim-with-cutadapt)
  * [What is next?](#what-is-next-)
- [Supplementary commands](#supplementary-commands)
  * [Manage packages](#manage-packages)
  * [Manage environments](#manage-environments)
  * [Share environments](#share-environments)
- [Conclusion](#conclusion)
- [References](#references)

## Introduction

High Throughput Sequencing (HTS) or Next-Generation Sequencing (NGS) technologies generate a massive number of sequence reads (a succession of nucleotides). However, they will generate different types and amount of errors, such as incorrect nucleotides being called. Therefore, the first step in HTS data analysis often is to understand, identify and exclude error-types that may impact the interpretation of downstream analysis. 

This tutorial will provide hands-on experience performing quality control checks and how to get your data analysis ready with the tools FastQC and Cutadapt using Conda packages.

## Set up the Conda environment

### Install Miniconda

First of all, you need to install Conda. 

The fastest way to obtain conda is to install Miniconda, a free minimal installer for conda. Follow instructions in the Conda [documentation](https://docs.conda.io/projects/conda/en/latest/user-guide/install/). Python 3 is a prerequisite.

Update conda to the current version if needed:

    conda update conda
    
Check conda with the following command: 

    conda info 

### Set up channels

Conda channels are the locations where packages are stored. They serve as the base for hosting and managing packages. Conda packages are downloaded from remote channels, which are URLs to directories containing conda packages.
You will need to add the bioconda channel as well as the other channels bioconda depends on. It is important to add them in this order so that the priority is set correctly (that is, conda-forge is highest priority).
Run the following commands:

    conda config --add channels defaults
    conda config --add channels bioconda
    conda config --add channels conda-forge

*You could also add desired channels by manually editing  `.condarc` file, located in your home folder `~/.condarc`.*

### Search for tool packages

To perform the NGS sequence quality control, you need two tools: FastQC and Cutadapt. Check if Conda packages are available for them, and which version.

    conda search fastqc
    conda search cutadapt

The `conda search` command searches for packages in the currently configured channels and displays associated information (origin channel, version and build numbers). 
    
*Additional channels to search for packages can be given with the `-c, --channel` option. They are searched in the order they are given and before the currently configured channels (unless --override-channels is given).*

If there is no Conda package for your favorite tool, please build it by writing a new recipe! This part will be described in the next tutorials.
The documentation and guidelines can be found here: https://bioconda.github.io/contributor/index.html

### Create a conda environment

You know that the Conda packages for your tools are available. How do you install them? 

The best practice is to create a Conda environment.

A Conda environment is a directory that contains a specific collection of conda packages that you have installed. For example, you may have one environment with NumPy 1.7 and its dependencies, and another environment with NumPy 1.6 for legacy testing. If you change one environment, your other environments are not affected. You can easily activate or deactivate environments, which is how you switch between them. 

The following command will create an environment with both tools for sequence quality checks:

    conda create -n quality_control fastqc cutadapt
    
You can also specify different release numbers:

    conda create -n quality_control fastqc=0.11.8 cutadapt=2.9

The conda environment is ready!

You can activate the conda environment and check the tools:

    conda activate quality_control
    fastqc --version
    cutadapt --version
   
*Note that it is also possible to create the environment in a first step and install the packages in a second step:*

    conda create -n quality_control
    conda activate quality_control
    conda install fastqc cutadapt

To deactivate the conda environment:

    conda deactivate

**Here, we have prepared a single environment with all the tools. In case of incompatibilities, as for example two software which require python2 and python3, it's recommanded to create separated environments and activate them just before using it.**

Now, let's start using the conda environment and start analysing the sequencing data!

## Run the sequence control quality in the Conda environment

### Introduction to the fastq format

The data we get directly from a sequencing facility are FASTQ files. In a FASTQ file, each read is encoded by 4 lines: line 1 (and optionally line 3) contains ID and descriptions, line 2 is the actual nucleic sequence, and line 4 are quality scores for each base of the sequence encoded as ASCII symbols.

An example from the `datasets/reads-fw.fastq` file:

    @SRR031714.9938 HWI-EAS299_130MNEAAXX:2:1:1376:650/2
    TGAGATTACACTGGAGGATGTACTCTTTTGTAAGGAA
    +
    IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII6II

*A detailed explanation of the FASTQ format is beyond the scope of this tutorial. You can find more information at [this page](https://training.galaxyproject.org/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html#inspect-a-raw-sequence-file).*

### Get the data

Download the sample raw data at https://github.com/eosc-life/WP2_workshop_tool_packaging/ngs_sequence_control_quality/datasets/reads-fw.fastq or with `git clone git@github.com:eosc-life/WP2_workshop_tool_packaging.git` and `cd WP2_workshop_tool_packaging/ngs_sequence_control_quality/datasets`

### Control quality with FastQC

To estimate sequence quality, we use [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). 

Run FastQC on the raw data file (don't forget to activate the conda environment!):

    fastqc --quiet --extract -f 'fastq' reads-fw.fastq
    
FastQC generates an HTML report for each input files, with multiple diagnostic plots.

Below is the plot representing per base sequence quality. 

![per base quality](images/per_base_quality.png)

On the x-axis are the base position in the read. In this example, the sample contains reads that are 37 base pairs long. The y-axis shows the quality scores. The higher the score, the better the base call. The background of the graph divides the y-axis into very good quality scores (green), scores of reasonable quality (orange), and reads of poor quality (red).

*To go into detail about this plot and other plots generated by FastQC, have a look at [this page]( https://training.galaxyproject.org/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html#assess-the-read-quality).*

### Filter and trim with Cutadapt

The quality of the sequences drops at the end of the sequences with potentially incorrectly called nucleotides. Sequences must be filtered and trimmed to reduce bias in downstream analysis. 

To accomplish this task we will use [Cutadapt](https://cutadapt.readthedocs.io/en/stable/guide.html).

Run Cutadapt:

    cutadapt --output='reads-fw-trim.fastq' --error-rate=0.1 --times=1 --overlap=3 --minimum-length=20 --quality-cutoff=20 reads-fw.fastq > report.txt

Run FastQC again on the trimmed data file to control the quality:

    fastqc --quiet --extract -f 'fastq' reads-fw-trim.fastq

The quality of the previous dataset was pretty good from the beginning and we improved it with trimming and filtering step (in a reasonable way to not lose too much information).

### What is next?

You can now deactivate your Conda environment:

    conda deactivate

You have checked the quality of your fastq file to ensure that the data looks good before inferring any further information. This step is the usual first step for analyses such as RNA-Seq, ChIP-Seq, or any other OMIC analysis relying on NGS data. 

You can now create and manage other Conda environments for whatever further OMIC analysis you want to do!

*If you are interested, further information on OMIC analyses can be found in the [Galaxy training tutorials](https://training.galaxyproject.org/training-material/).*

## Supplementary commands

Other commands can be useful to manage packages or environments or to share environments.

### Manage packages

List all packages and versions in an active environment:

    conda list

List all packages and versions in a named environment:

    conda list --name ENVNAME

Update all packages within an environment:

    conda update --all --name ENVNAME

Remove a package from an environment:

    conda uninstall PKGNAME --name ENVNAME

### Manage environments

List all available environments:

    conda env list

Make an exact copy of an environment:

    conda create --clone ENVNAME --name NEWENV

Delete an entire environment:

    conda remove --name ENVNAME --all

### Share environments

Export an environment to a YAML file:

    conda env export --name ENVNAME > envname.yml

Create an environment from YAML file:

    conda env create --file envname.yml

## Conclusion

In this tutorial, we have seen the main useful commands of Conda: they are all available in the **Conda [cheat sheet](https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html#)**.

We also got a glimpse of the pre-processing steps needed before any NGS sequence analysis: quality control with a tool like FastQC and trimming with a tool like Cutadapt.

## References

1. Conda [cheat sheet](https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html#)
2. Conda [documentation](https://docs.conda.io)
3. Bioconda channel [documentation](https://bioconda.github.io) and [contribution guidelines](https://bioconda.github.io/contributor/index.html)
4. Bérénice Batut, 2020 Quality Control (Galaxy Training Materials). [/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html](https://training.galaxyproject.org/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html) Online; accessed Thu Jul 09 2020 
5. Anton Nekrutenko, 2020 NGS data logistics (Galaxy Training Materials). [/training-material/topics/introduction/tutorials/galaxy-intro-ngs-data-managment/tutorial.html](https://training.galaxyproject.org/training-material/topics/introduction/tutorials/galaxy-intro-ngs-data-managment/tutorial.html) Online; accessed Fri Jul 10 2020 
