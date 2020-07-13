# Example of the use of Conda packages for NGS sequence quality control

**Objective**: Learn how to use conda packages and some best practices through a simple NGS sequence analysis (sequence quality control)

**Requirements**: 
- Basic unix commands knowledge
- Unix OS (linux or osx)
- Python 3 installed 
- Conda 3 installed (see [Install Miniconda](#install-miniconda))

**Time estimation**: 20 minutes

**Table of content**:

- [Introduction](#introduction)
- [Set up Conda environments](#set-up-conda-environments)
  * [Install Miniconda](#install-miniconda)
  * [Set up channels](#set-up-channels)
  * [Search for tool packages](#search-for-tool-packages)
  * [Create Conda environments](#create-conda-environments)
- [Run the sequence control quality in the Conda environment](#run-the-sequence-control-quality-in-the-conda-environment)
  * [Get the data](#get-the-data)
  * [Introduction to the fastq format](#introduction-to-the-fastq-format)
  * [Control quality with FastQC](#control-quality-with-fastqc)
  * [Filter and trim with Cutadapt](#filter-and-trim-with-cutadapt)
  * [What is next?](#what-is-next-)
- [Conda and reproducible science](#conda-and-reproducible-science)
- [Conclusion](#conclusion)
- [References](#references)

## Introduction

High Throughput Sequencing (HTS) or Next-Generation Sequencing (NGS) technologies generate a massive number of sequence reads (a succession of nucleotides). However, they will generate different types and amount of errors, such as incorrect nucleotides being called. Therefore, the first step in HTS data analysis often is to understand, identify and exclude error-types that may impact the interpretation of downstream analysis. 

This tutorial will provide hands-on experience using Conda packages to perform quality control checks and get your data ready for downstream analysis with the tools FastQC and Cutadapt.

## Set up Conda environments

### Install Miniconda

First of all, you need to install Conda. 

The fastest way to obtain conda is to install Miniconda, a free minimal installer for Conda. Follow instructions in the Conda [documentation](https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html). Python 3 is a prerequisite.

Update conda to the current version if needed:

    conda update conda
    
Check conda with the following command: 

    conda info 

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda info

     active environment : base
    active env location : /home/fr2424/sib/lgueguen/miniconda3
            shell level : 1
       user config file : /home/fr2424/sib/lgueguen/.condarc
 populated config files :
          conda version : 4.8.3
    conda-build version : not installed
         python version : 3.7.7.final.0
       virtual packages : __glibc=2.12
       base environment : /home/fr2424/sib/lgueguen/miniconda3  (writable)
           channel URLs : https://repo.anaconda.com/pkgs/main/linux-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/linux-64
                          https://repo.anaconda.com/pkgs/r/noarch
          package cache : /home/fr2424/sib/lgueguen/miniconda3/pkgs
                          /home/fr2424/sib/lgueguen/.conda/pkgs
       envs directories : /home/fr2424/sib/lgueguen/miniconda3/envs
                          /home/fr2424/sib/lgueguen/.conda/envs
               platform : linux-64
             user-agent : conda/4.8.3 requests/2.24.0 CPython/3.7.7 Linux/2.6.32-431.17.1.el6.x86_64 centos/6.5 glibc/2.12
                UID:GID : 2369:1000
             netrc file : None
           offline mode : False
```    
</details>

### Set up channels

Conda channels are the locations where packages are stored. They serve as the base for hosting and managing packages. Conda packages are downloaded from remote channels, which are URLs to directories containing conda packages.
You will need to add the bioconda channel as well as the other channels bioconda depends on. It is important to add them in this order so that the priority is set correctly (that is, conda-forge is highest priority).

Run the following commands:

    conda config --add channels defaults
    conda config --add channels bioconda
    conda config --add channels conda-forge

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda config --add channels defaults
Warning: 'defaults' already in 'channels' list, moving to the top
(base) [lgueguen@n221 demo]$ conda config --add channels bioconda
(base) [lgueguen@n221 demo]$ conda config --add channels conda-forge
(base) [lgueguen@n221 demo]$ conda info

     active environment : base
    active env location : /home/fr2424/sib/lgueguen/miniconda3
            shell level : 1
       user config file : /home/fr2424/sib/lgueguen/.condarc
 populated config files : /home/fr2424/sib/lgueguen/.condarc
          conda version : 4.8.3
    conda-build version : not installed
         python version : 3.7.7.final.0
       virtual packages : __glibc=2.12
       base environment : /home/fr2424/sib/lgueguen/miniconda3  (writable)
           channel URLs : https://conda.anaconda.org/conda-forge/linux-64
                          https://conda.anaconda.org/conda-forge/noarch
                          https://conda.anaconda.org/bioconda/linux-64
                          https://conda.anaconda.org/bioconda/noarch
                          https://repo.anaconda.com/pkgs/main/linux-64
                          https://repo.anaconda.com/pkgs/main/noarch
                          https://repo.anaconda.com/pkgs/r/linux-64
                          https://repo.anaconda.com/pkgs/r/noarch
          package cache : /home/fr2424/sib/lgueguen/miniconda3/pkgs
                          /home/fr2424/sib/lgueguen/.conda/pkgs
       envs directories : /home/fr2424/sib/lgueguen/miniconda3/envs
                          /home/fr2424/sib/lgueguen/.conda/envs
               platform : linux-64
             user-agent : conda/4.8.3 requests/2.24.0 CPython/3.7.7 Linux/2.6.32-431.17.1.el6.x86_64 centos/6.5 glibc/2.12
                UID:GID : 2369:1000
             netrc file : None
           offline mode : False
```    
</details>
</br>

The `conda config` command updates the `.condarc` file, located in your home folder `~/.condarc`.

    cat ~/.condarc

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ cat ~/.condarc
channels:
  - conda-forge
  - bioconda
  - defaults
```    
</details>
</br>


*You can also add desired channels by manually editing the `.condarc` file.*

### Search for tool packages

To perform the NGS sequence quality control, you need two tools: FastQC (0.11.9) and Cutadapt (2.10). These are not available in your terminal:

    which fastqc
    which cutadapt

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ which fastqc
/usr/bin/which: no fastqc in (/opt/python/bin:/opt/python3/bin:/opt/pypy/bin:/opt/pypy3/bin:/usr/local/java/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/dell/srvadmin/bin:/usr/local/public/bin:/home/fr2424/sib/lgueguen/bin:/home/fr2424/sib/lgueguen/bin)
(base) [lgueguen@n221 demo]$ which cutadapt
/usr/bin/which: no cutadapt in (/opt/python/bin:/opt/python3/bin:/opt/pypy/bin:/opt/pypy3/bin:/usr/local/java/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/dell/srvadmin/bin:/usr/local/public/bin:/home/fr2424/sib/lgueguen/bin:/home/fr2424/sib/lgueguen/bin)
```    
</details>
</br>

Check if Conda packages are available for them, and which version.

    conda search fastqc
    conda search cutadapt

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda search fastqc
Loading channels: done
# Name                       Version           Build  Channel
fastqc                        0.10.1               0  bioconda
fastqc                        0.10.1               1  bioconda
fastqc                        0.11.2               1  bioconda
fastqc                        0.11.2      pl5.22.0_0  bioconda
fastqc                        0.11.3               0  bioconda
fastqc                        0.11.3               1  bioconda
fastqc                        0.11.4               0  bioconda
fastqc                        0.11.4               1  bioconda
fastqc                        0.11.4               2  bioconda
fastqc                        0.11.5               1  bioconda
fastqc                        0.11.5               4  bioconda
fastqc                        0.11.5      pl5.22.0_2  bioconda
fastqc                        0.11.5      pl5.22.0_3  bioconda
fastqc                        0.11.6               2  bioconda
fastqc                        0.11.6      pl5.22.0_0  bioconda
fastqc                        0.11.6      pl5.22.0_1  bioconda
fastqc                        0.11.7               4  bioconda
fastqc                        0.11.7               5  bioconda
fastqc                        0.11.7               6  bioconda
fastqc                        0.11.7      pl5.22.0_0  bioconda
fastqc                        0.11.7      pl5.22.0_2  bioconda
fastqc                        0.11.8               0  bioconda
fastqc                        0.11.8               1  bioconda
fastqc                        0.11.8               2  bioconda
fastqc                        0.11.9               0  bioconda
(base) [lgueguen@n221 demo]$ conda search cutadapt
Loading channels: done
# Name                       Version           Build  Channel
cutadapt                       1.8.1          py34_0  bioconda
cutadapt                       1.8.3          py27_0  bioconda
cutadapt                       1.8.3          py34_0  bioconda
cutadapt                       1.8.3          py35_0  bioconda
cutadapt                       1.9.1          py27_0  bioconda
cutadapt                       1.9.1          py34_0  bioconda
cutadapt                       1.9.1          py35_0  bioconda
cutadapt                        1.10          py27_0  bioconda
cutadapt                        1.10          py34_0  bioconda
cutadapt                        1.10          py35_0  bioconda
cutadapt                        1.11          py27_0  bioconda
cutadapt                        1.11          py34_0  bioconda
cutadapt                        1.11          py35_0  bioconda
cutadapt                        1.12          py27_0  bioconda
cutadapt                        1.12          py27_1  bioconda
cutadapt                        1.12          py34_0  bioconda
cutadapt                        1.12          py34_1  bioconda
cutadapt                        1.12          py35_0  bioconda
cutadapt                        1.12          py35_1  bioconda
cutadapt                        1.13          py27_0  bioconda
cutadapt                        1.13          py34_0  bioconda
cutadapt                        1.13          py35_0  bioconda
cutadapt                        1.13          py36_0  bioconda
cutadapt                        1.14          py27_0  bioconda
cutadapt                        1.14          py35_0  bioconda
cutadapt                        1.14          py36_0  bioconda
cutadapt                        1.15          py27_0  bioconda
cutadapt                        1.15          py35_0  bioconda
cutadapt                        1.15          py36_0  bioconda
cutadapt                        1.16          py27_0  bioconda
cutadapt                        1.16          py27_1  bioconda
cutadapt                        1.16          py27_2  bioconda
cutadapt                        1.16          py35_0  bioconda
cutadapt                        1.16          py35_1  bioconda
cutadapt                        1.16          py35_2  bioconda
cutadapt                        1.16          py36_0  bioconda
cutadapt                        1.16          py36_1  bioconda
cutadapt                        1.16          py36_2  bioconda
cutadapt                        1.17          py27_0  bioconda
cutadapt                        1.17          py35_0  bioconda
cutadapt                        1.17          py36_0  bioconda
cutadapt                        1.18          py27_0  bioconda
cutadapt                        1.18  py27h14c3975_1  bioconda
cutadapt                        1.18          py35_0  bioconda
cutadapt                        1.18          py36_0  bioconda
cutadapt                        1.18  py36h14c3975_1  bioconda
cutadapt                        1.18  py37h14c3975_1  bioconda
cutadapt                         2.0  py36h14c3975_0  bioconda
cutadapt                         2.0  py37h14c3975_0  bioconda
cutadapt                         2.1  py36h14c3975_0  bioconda
cutadapt                         2.1  py37h14c3975_0  bioconda
cutadapt                         2.2  py36h14c3975_0  bioconda
cutadapt                         2.2  py37h14c3975_0  bioconda
cutadapt                         2.3  py36h14c3975_0  bioconda
cutadapt                         2.3  py37h14c3975_0  bioconda
cutadapt                         2.4  py36h14c3975_0  bioconda
cutadapt                         2.4  py37h14c3975_0  bioconda
cutadapt                         2.5  py36h516909a_0  bioconda
cutadapt                         2.5  py37h516909a_0  bioconda
cutadapt                         2.6  py36h516909a_0  bioconda
cutadapt                         2.6  py37h516909a_0  bioconda
cutadapt                         2.7  py36h516909a_0  bioconda
cutadapt                         2.7  py37h516909a_0  bioconda
cutadapt                         2.8  py36h516909a_0  bioconda
cutadapt                         2.8  py37h516909a_0  bioconda
cutadapt                         2.9  py36h516909a_0  bioconda
cutadapt                         2.9  py37h516909a_0  bioconda
cutadapt                        2.10  py36h4c5857e_1  bioconda
cutadapt                        2.10  py36h516909a_0  bioconda
cutadapt                        2.10  py37h516909a_0  bioconda
cutadapt                        2.10  py37hf01694f_1  bioconda
```    
</details>
</br>

The `conda search` command searches for packages in the currently configured channels and displays associated information (origin channel, version and build numbers). 
    
*Additional channels to search for packages can be given with the `-c, --channel` option. They are searched in the order they are given and before the currently configured channels (unless --override-channels is given).*

You can also search for your tool directly on the [Bioconda website](https://bioconda.github.io):
- [web page for the fastqc package](https://bioconda.github.io/recipes/fastqc/README.html)
- [web page for the cutadapt package](https://bioconda.github.io/recipes/cutadapt/README.html)

If there is no Conda package for your favorite tool, please build it by writing a new recipe! This part will be described in the next tutorials.
The documentation and guidelines can be found here: https://bioconda.github.io/contributor/index.html

### Create Conda environments

You know that the Conda packages for your tools are available. How do you install them? 

Not in the base environment because it will quickly get messy and you will have dependencies conflicts! The best practice is to create one Conda environment for each version of each tool (we will talk about it afterwards in section [Conda and reproducible science](#conda-and-reproducible-science))

A Conda environment is a directory that contains a specific collection of conda packages that you have installed. For example, you may have one environment with NumPy 1.7 and its dependencies, and another environment with NumPy 1.6 for legacy testing. If you change one environment, your other environments are not affected. You can easily activate or deactivate environments, which is how you switch between them. 

The following command will create an environment with both tools for sequence quality checks:

    conda create -n fastqc-0.11.9 fastqc=0.11.9
    conda create -n cutadapt-2.10 cutadapt=2.10

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda create -n fastqc-0.11.9 fastqc=0.11.9
Collecting package metadata (current_repodata.json): done
Solving environment: done

## Package Plan ##

  environment location: /home/fr2424/sib/lgueguen/miniconda3/envs/fastqc-0.11.9

  added / updated specs:
    - fastqc=0.11.9


The following NEW packages will be INSTALLED:

  _libgcc_mutex      conda-forge/linux-64::_libgcc_mutex-0.1-conda_forge
  _openmp_mutex      conda-forge/linux-64::_openmp_mutex-4.5-0_gnu
  alsa-lib           conda-forge/linux-64::alsa-lib-1.1.5-h516909a_1002
  fastqc             bioconda/noarch::fastqc-0.11.9-0
  font-ttf-dejavu-s~ conda-forge/noarch::font-ttf-dejavu-sans-mono-2.37-hab24e00_0
  fontconfig         conda-forge/linux-64::fontconfig-2.13.1-h1056068_1002
  freetype           conda-forge/linux-64::freetype-2.10.2-he06d7ca_0
  giflib             conda-forge/linux-64::giflib-5.2.1-h516909a_2
  icu                conda-forge/linux-64::icu-67.1-he1b5a44_0
  jpeg               conda-forge/linux-64::jpeg-9d-h516909a_0
  lcms2              conda-forge/linux-64::lcms2-2.11-hbd6801e_0
  libgcc-ng          conda-forge/linux-64::libgcc-ng-9.2.0-h24d8f2e_2
  libgomp            conda-forge/linux-64::libgomp-9.2.0-h24d8f2e_2
  libiconv           conda-forge/linux-64::libiconv-1.15-h516909a_1006
  libpng             conda-forge/linux-64::libpng-1.6.37-hed695b0_1
  libstdcxx-ng       conda-forge/linux-64::libstdcxx-ng-9.2.0-hdf63c60_2
  libtiff            conda-forge/linux-64::libtiff-4.1.0-hc7e4089_6
  libuuid            conda-forge/linux-64::libuuid-2.32.1-h14c3975_1000
  libwebp-base       conda-forge/linux-64::libwebp-base-1.1.0-h516909a_3
  libxcb             conda-forge/linux-64::libxcb-1.13-h14c3975_1002
  libxml2            conda-forge/linux-64::libxml2-2.9.10-h72b56ed_1
  lz4-c              conda-forge/linux-64::lz4-c-1.9.2-he1b5a44_1
  openjdk            conda-forge/linux-64::openjdk-11.0.1-h600c080_1018
  perl               conda-forge/linux-64::perl-5.26.2-h516909a_1006
  pthread-stubs      conda-forge/linux-64::pthread-stubs-0.4-h14c3975_1001
  xorg-fixesproto    conda-forge/linux-64::xorg-fixesproto-5.0-h14c3975_1002
  xorg-inputproto    conda-forge/linux-64::xorg-inputproto-2.3.2-h14c3975_1002
  xorg-kbproto       conda-forge/linux-64::xorg-kbproto-1.0.7-h14c3975_1002
  xorg-libx11        conda-forge/linux-64::xorg-libx11-1.6.9-h516909a_0
  xorg-libxau        conda-forge/linux-64::xorg-libxau-1.0.9-h14c3975_0
  xorg-libxdmcp      conda-forge/linux-64::xorg-libxdmcp-1.1.3-h516909a_0
  xorg-libxext       conda-forge/linux-64::xorg-libxext-1.3.4-h516909a_0
  xorg-libxfixes     conda-forge/linux-64::xorg-libxfixes-5.0.3-h516909a_1004
  xorg-libxi         conda-forge/linux-64::xorg-libxi-1.7.10-h516909a_0
  xorg-libxrender    conda-forge/linux-64::xorg-libxrender-0.9.10-h516909a_1002
  xorg-libxtst       conda-forge/linux-64::xorg-libxtst-1.2.3-h516909a_1002
  xorg-recordproto   conda-forge/linux-64::xorg-recordproto-1.14.2-h516909a_1002
  xorg-renderproto   conda-forge/linux-64::xorg-renderproto-0.11.1-h14c3975_1002
  xorg-xextproto     conda-forge/linux-64::xorg-xextproto-7.3.0-h14c3975_1002
  xorg-xproto        conda-forge/linux-64::xorg-xproto-7.0.31-h14c3975_1007
  xz                 conda-forge/linux-64::xz-5.2.5-h516909a_1
  zlib               conda-forge/linux-64::zlib-1.2.11-h516909a_1006
  zstd               conda-forge/linux-64::zstd-1.4.4-h6597ccf_3


Proceed ([y]/n)? y

Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use
#
#     $ conda activate fastqc-0.11.9
#
# To deactivate an active environment, use
#
#     $ conda deactivate

(base) [lgueguen@n221 demo]$ conda create -n cutadapt-2.10 cutadapt=2.10
Collecting package metadata (current_repodata.json): done
Solving environment: done

## Package Plan ##

  environment location: /home/fr2424/sib/lgueguen/miniconda3/envs/cutadapt-2.10

  added / updated specs:
    - cutadapt=2.10


The following NEW packages will be INSTALLED:

  _libgcc_mutex      conda-forge/linux-64::_libgcc_mutex-0.1-conda_forge
  _openmp_mutex      conda-forge/linux-64::_openmp_mutex-4.5-0_gnu
  ca-certificates    conda-forge/linux-64::ca-certificates-2020.6.20-hecda079_0
  certifi            conda-forge/linux-64::certifi-2020.6.20-py37hc8dfbb8_0
  cutadapt           bioconda/linux-64::cutadapt-2.10-py37hf01694f_1
  dnaio              bioconda/linux-64::dnaio-0.4.2-py37hf01694f_1
  ld_impl_linux-64   conda-forge/linux-64::ld_impl_linux-64-2.34-h53a641e_7
  libffi             conda-forge/linux-64::libffi-3.2.1-he1b5a44_1007
  libgcc-ng          conda-forge/linux-64::libgcc-ng-9.2.0-h24d8f2e_2
  libgomp            conda-forge/linux-64::libgomp-9.2.0-h24d8f2e_2
  libstdcxx-ng       conda-forge/linux-64::libstdcxx-ng-9.2.0-hdf63c60_2
  ncurses            conda-forge/linux-64::ncurses-6.1-hf484d3e_1002
  openssl            conda-forge/linux-64::openssl-1.1.1g-h516909a_0
  pigz               conda-forge/linux-64::pigz-2.3.4-hed695b0_1
  pip                conda-forge/noarch::pip-20.1.1-py_1
  python             conda-forge/linux-64::python-3.7.6-cpython_h8356626_6
  python_abi         conda-forge/linux-64::python_abi-3.7-1_cp37m
  readline           conda-forge/linux-64::readline-8.0-h46ee950_1
  setuptools         conda-forge/linux-64::setuptools-49.2.0-py37hc8dfbb8_0
  sqlite             conda-forge/linux-64::sqlite-3.32.3-hcee41ef_1
  tk                 conda-forge/linux-64::tk-8.6.10-hed695b0_0
  wheel              conda-forge/noarch::wheel-0.34.2-py_1
  xopen              conda-forge/linux-64::xopen-0.9.0-py37hc8dfbb8_0
  xz                 conda-forge/linux-64::xz-5.2.5-h516909a_1
  zlib               conda-forge/linux-64::zlib-1.2.11-h516909a_1006


Proceed ([y]/n)? y

Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use
#
#     $ conda activate cutadapt-2.10
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```    
</details>
</br>

*If the tool version is omitted (e.g `=0.11.9`), the latest version of the tool will be installed:*

    conda create -n fastqc fastqc

You can list all available environments with:

    conda env list

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda env list
# conda environments:
#
base                  *  /home/fr2424/sib/lgueguen/miniconda3
cutadapt-2.10            /home/fr2424/sib/lgueguen/miniconda3/envs/cutadapt-2.10
fastqc-0.11.9            /home/fr2424/sib/lgueguen/miniconda3/envs/fastqc-0.11.9
```    
</details>
</br>

You can activate and deactivate an environment with the following commands:

    conda activate ENVNAME
    conda deactivate

Now, activate one environment, and check that the tool is available: 

    conda activate fastqc-0.11.9
    which fastqc

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda activate fastqc-0.11.9
(fastqc-0.11.9) [lgueguen@n221 demo]$ which fastqc
~/miniconda3/envs/fastqc-0.11.9/bin/fastqc
```    
</details>
</br>

FastQC has been installed, along with all necessary dependencies. You can display them with:

    conda list

<details>
    <summary>shell prompt</summary>

```console
(fastqc-0.11.9) [lgueguen@n221 demo]$ conda list
# packages in environment at /home/fr2424/sib/lgueguen/miniconda3/envs/fastqc-0.11.9:
#
# Name                    Version                   Build  Channel
_libgcc_mutex             0.1                 conda_forge    conda-forge
_openmp_mutex             4.5                       0_gnu    conda-forge
alsa-lib                  1.1.5             h516909a_1002    conda-forge
fastqc                    0.11.9                        0    bioconda
font-ttf-dejavu-sans-mono 2.37                 hab24e00_0    conda-forge
fontconfig                2.13.1            h1056068_1002    conda-forge
freetype                  2.10.2               he06d7ca_0    conda-forge
giflib                    5.2.1                h516909a_2    conda-forge
icu                       67.1                 he1b5a44_0    conda-forge
jpeg                      9d                   h516909a_0    conda-forge
lcms2                     2.11                 hbd6801e_0    conda-forge
libgcc-ng                 9.2.0                h24d8f2e_2    conda-forge
libgomp                   9.2.0                h24d8f2e_2    conda-forge
libiconv                  1.15              h516909a_1006    conda-forge
libpng                    1.6.37               hed695b0_1    conda-forge
libstdcxx-ng              9.2.0                hdf63c60_2    conda-forge
libtiff                   4.1.0                hc7e4089_6    conda-forge
libuuid                   2.32.1            h14c3975_1000    conda-forge
libwebp-base              1.1.0                h516909a_3    conda-forge
libxcb                    1.13              h14c3975_1002    conda-forge
libxml2                   2.9.10               h72b56ed_1    conda-forge
lz4-c                     1.9.2                he1b5a44_1    conda-forge
openjdk                   11.0.1            h600c080_1018    conda-forge
perl                      5.26.2            h516909a_1006    conda-forge
pthread-stubs             0.4               h14c3975_1001    conda-forge
xorg-fixesproto           5.0               h14c3975_1002    conda-forge
xorg-inputproto           2.3.2             h14c3975_1002    conda-forge
xorg-kbproto              1.0.7             h14c3975_1002    conda-forge
xorg-libx11               1.6.9                h516909a_0    conda-forge
xorg-libxau               1.0.9                h14c3975_0    conda-forge
xorg-libxdmcp             1.1.3                h516909a_0    conda-forge
xorg-libxext              1.3.4                h516909a_0    conda-forge
xorg-libxfixes            5.0.3             h516909a_1004    conda-forge
xorg-libxi                1.7.10               h516909a_0    conda-forge
xorg-libxrender           0.9.10            h516909a_1002    conda-forge
xorg-libxtst              1.2.3             h516909a_1002    conda-forge
xorg-recordproto          1.14.2            h516909a_1002    conda-forge
xorg-renderproto          0.11.1            h14c3975_1002    conda-forge
xorg-xextproto            7.3.0             h14c3975_1002    conda-forge
xorg-xproto               7.0.31            h14c3975_1007    conda-forge
xz                        5.2.5                h516909a_1    conda-forge
zlib                      1.2.11            h516909a_1006    conda-forge
zstd                      1.4.4                h6597ccf_3    conda-forge
(fastqc-0.11.9) [lgueguen@n221 demo]$ conda deactivate
```    
</details>
</br>

*Note that it is possible to install, update and uninstall packages with the following commands:*

    conda install PKGNAME1 [PKGNAME2...] # install packages
    conda update --all # update all packages
    conda uninstall PKGNAME # uninstall a package

*There are similar commands for an unactivated environment, with option `-n ENVNAME` (e.g. `conda install -n ENVNAME PKGNAME`)*

Your Conda environments are ready to use! Let's start using them for analyzing the sequencing data!

## Run the sequence control quality in the Conda environment

### Get the data

Download the sample raw data `reads-fw.fastq`:

    wget https://github.com/eosc-life/WP2_workshop_tool_packaging/raw/master/ngs_sequence_quality_control/datasets/reads-fw.fastq

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 ngs_sequence_quality_control]$ wget https://github.com/eosc-life/WP2_workshop_tool_packaging/raw/master/ngs_sequence_quality_control/datasets/reads-fw.fastq
--2020-07-13 19:25:08--  https://github.com/eosc-life/WP2_workshop_tool_packaging/raw/master/ngs_sequence_quality_control/datasets/reads-fw.fastq
Resolving github.com... 140.82.118.3
Connecting to github.com|140.82.118.3|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://raw.githubusercontent.com/eosc-life/WP2_workshop_tool_packaging/master/ngs_sequence_quality_control/datasets/reads-fw.fastq [following]
--2020-07-13 19:25:08--  https://raw.githubusercontent.com/eosc-life/WP2_workshop_tool_packaging/master/ngs_sequence_quality_control/datasets/reads-fw.fastq
Resolving raw.githubusercontent.com... 151.101.120.133
Connecting to raw.githubusercontent.com|151.101.120.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1310295 (1.2M) [text/plain]
Saving to: “reads-fw.fastq”

100%[===============================================================================================================>] 1,310,295   --.-K/s   in 0.1s

2020-07-13 19:25:09 (8.73 MB/s) - “reads-fw.fastq” saved [1310295/1310295]

    (base) [lgueguen@n221 demo]$ ls
reads-fw.fastq
```    
</details>

### Introduction to the fastq format

The data we get directly from a sequencing facility are FASTQ files. In a FASTQ file, each read is encoded by 4 lines: line 1 (and optionally line 3) contains ID and descriptions, line 2 is the actual nucleic sequence, and line 4 are quality scores for each base of the sequence encoded as ASCII symbols.

An example sequence from the `reads-fw.fastq` file:

    @SRR031714.9938 HWI-EAS299_130MNEAAXX:2:1:1376:650/2
    TGAGATTACACTGGAGGATGTACTCTTTTGTAAGGAA
    +
    IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII6II

*A detailed explanation of the FASTQ format is beyond the scope of this tutorial. You can find more information at [this page](https://training.galaxyproject.org/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html#inspect-a-raw-sequence-file).*

### Control quality with FastQC

To estimate sequence quality, we use [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). 

Run FastQC on the raw data file (don't forget to activate the conda environment!):

    conda activate fastqc-0.11.9
    fastqc --quiet --extract -f 'fastq' reads-fw.fastq
    conda deactivate

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda activate fastqc-0.11.9
(fastqc-0.11.9) [lgueguen@n221 demo]$ fastqc --quiet --extract -f 'fastq' reads-fw.fastq
(fastqc-0.11.9) [lgueguen@n221 demo]$ ls
reads-fw.fastq  reads-fw_fastqc  reads-fw_fastqc.html  reads-fw_fastqc.zip
(fastqc-0.11.9) [lgueguen@n221 demo]$ conda deactivate
```    
</details>
</br>

FastQC generates an [HTML report](datasets/reads-fw_fastqc.html), with multiple diagnostic plots.

Below is the plot representing per base sequence quality. 

![raw_per base quality](datasets/reads-fw_fastqc/images/per_base_quality.png)

On the x-axis are the base position in the read. In this example, the sample contains reads that are 37 base pairs long. The y-axis shows the quality scores. The higher the score, the better the base call. The background of the graph divides the y-axis into very good quality scores (green), scores of reasonable quality (orange), and reads of poor quality (red).

*To go into detail about this plot and other plots generated by FastQC, have a look at [this page]( https://training.galaxyproject.org/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html#assess-the-read-quality).*

### Filter and trim with Cutadapt

The quality of the sequences drops at the end of the sequences with potentially incorrectly called nucleotides. Sequences must be filtered and trimmed to reduce bias in downstream analysis. 

To accomplish this task we will use [Cutadapt](https://cutadapt.readthedocs.io/en/stable/guide.html).

Run Cutadapt (don't forget to switch the conda environment!):

    conda activate cutadapt-2.10
    cutadapt --output='reads-fw-trim.fastq' --error-rate=0.1 --times=1 --overlap=3 --minimum-length=20 --quality-cutoff=20 reads-fw.fastq > report.txt
    conda deactivate

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda activate cutadapt-2.10
(cutadapt-2.10) [lgueguen@n221 demo]$ cutadapt --output='reads-fw-trim.fastq' --error-rate=0.1 --times=1 --overlap=3 --minimum-length=20 --quality-cutoff=20 reads-fw.fastq > report.txt
[8<----------] 00:00:00        10,000 reads  @     16.3 µs/read;   3.67 M reads/minute
(cutadapt-2.10) [lgueguen@n221 demo]$ ls
reads-fw.fastq  reads-fw_fastqc  reads-fw_fastqc.html  reads-fw_fastqc.zip  reads-fw-trim.fastq  report.txt
(cutadapt-2.10) [lgueguen@n221 demo]$ cat report.txt
This is cutadapt 2.10 with Python 3.7.6
Command line parameters: --output=reads-fw-trim.fastq --error-rate=0.1 --times=1 --overlap=3 --minimum-length=20 --quality-cutoff=20 reads-fw.fastq
Processing reads on 1 core in single-end mode ...
Finished in 0.18 s (18 us/read; 3.32 M reads/minute).

=== Summary ===

Total reads processed:                  10,000
Reads with adapters:                         0 (0.0%)
Reads written (passing filters):         9,988 (99.9%)

Total basepairs processed:       370,000 bp
Quality-trimmed:                   2,736 bp (0.7%)
Total written (filtered):        367,098 bp (99.2%)
(cutadapt-2.10) [lgueguen@n221 demo]$ conda deactivate
```    
</details>
</br>

Run FastQC again on the trimmed data file to control the quality (don't forget to switch the conda environment!):

    conda activate fastqc-0.11.9
    fastqc --quiet --extract -f 'fastq' reads-fw-trim.fastq
    conda deactivate

<details>
    <summary>shell prompt</summary>

```console
(base) [lgueguen@n221 demo]$ conda activate fastqc-0.11.9
(fastqc-0.11.9) [lgueguen@n221 demo]$ fastqc --quiet --extract -f 'fastq' reads-fw-trim.fastq
(fastqc-0.11.9) [lgueguen@n221 demo]$ ls
reads-fw.fastq   reads-fw_fastqc.html  reads-fw-trim.fastq   reads-fw-trim_fastqc.html  report.txt reads-fw_fastqc  reads-fw_fastqc.zip   reads-fw-trim_fastqc  reads-fw-trim_fastqc.zip
(fastqc-0.11.9) [lgueguen@n221 demo]$ conda deactivate
```    
</details>
</br>

The quality of the previous dataset was pretty good from the beginning and we improved it with trimming and filtering step (in a reasonable way to not lose too much information) as you can see on the plot below and on the [HTML report](datasets/reads-fw-trim_fastqc.html).

![trimmed_per base quality](datasets/reads-fw-trim_fastqc/images/per_base_quality.png)

### What is next?

You have checked the quality of your fastq file to ensure that the data looks good before inferring any further information. This step is the usual first step for analyses such as RNA-Seq, ChIP-Seq, or any other OMIC analysis relying on NGS data. 

You can now create and manage other Conda environments for whatever further OMIC analysis you want to do!

*If you are interested, further information and tutorials on OMIC analyses can be found in the [Galaxy training network](https://training.galaxyproject.org/training-material/).*

## Conda and reproducible science

Here, you have prepared a separated environment for each tool (FastQC and Cutadapt). But you could also have created a single environment with all the tools. In this case, it is best to install all packages at once, so that all of the dependencies are installed at the same time, avoiding dependency conflicts. (*Note that it is sometimes not possible to have all tools in a single environment, in case of dependency incompatibilities, as for example two software which require python2 and python3.*)

    conda create -n ENVNAME PKGNAME1 PKGNAME2
   
However, **it is a good practice for reproducible science to have one separated environment for each version of each tool** and switch between them when needed, **to keep track of which tool and which version has been used in your workflow**.

## Conclusion

In this tutorial, we have seen the main useful commands of Conda: they are all available in the **[Conda cheat sheet](https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html#)**.

We also got a glimpse of the pre-processing steps needed before any NGS sequence analysis: quality control with a tool like FastQC and trimming with a tool like Cutadapt.

## References

1. Conda [cheat sheet](https://docs.conda.io/projects/conda/en/latest/user-guide/cheatsheet.html#)
2. Conda [documentation](https://docs.conda.io)
3. Bioconda channel [documentation](https://bioconda.github.io) and [contribution guidelines](https://bioconda.github.io/contributor/index.html)
4. Bérénice Batut, 2020 Quality Control (Galaxy Training Materials). [/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html](https://training.galaxyproject.org/training-material/topics/sequence-analysis/tutorials/quality-control/tutorial.html) Online; accessed Thu Jul 09 2020 
5. Anton Nekrutenko, 2020 NGS data logistics (Galaxy Training Materials). [/training-material/topics/introduction/tutorials/galaxy-intro-ngs-data-managment/tutorial.html](https://training.galaxyproject.org/training-material/topics/introduction/tutorials/galaxy-intro-ngs-data-managment/tutorial.html) Online; accessed Fri Jul 10 2020 
