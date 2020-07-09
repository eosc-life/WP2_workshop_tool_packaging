# Build Your Own Conda Recipe - Cellprofiler

This tutorial aims to provide a step-by-step instruction on how to build your own conda recipe locally from scratch. Cellprofiler v3.1.9 was chosen as an example for illustration purpose, due to its popularity in the imaging field. The instructions in this tutorial can also be used as a general steps for creating recipe locally.

## Pre-requisite
This tutorial is based on the following software versions.
 1. Anaconda or Miniconda
 2. Python 2.7
 3. conda 4.8
 4. conda-build 3.18 

## Files

 1.  meta.yaml : The Cellprofiler conda recipe file
 2. LICENSE : License file for the conda recipe.
 3. ExampleHuman : An example from Cellprofiler website

## Steps

**1. Install Anaconda/Miniconda and conda-build**

Cellprofiler v3.1.9  only supports Python2 therefore you will need to download the respective version of Miniconda here https://docs.conda.io/projects/conda/en/latest/user-guide/install/

 Bioconda provides tools for testing recipe locally https://bioconda.github.io/contributor/building-locally.html#using-the-circle-ci-client

If you do not want to use the tool provided by Bioconda, you will need to install 'conda-build' to build the recipe locally.

**2. Update conda and install conda-build**
Update conda if you have old version of conda previously installed; install `conda-build` if local build is needed. 

     conda update conda
     conda install conda-build
Check conda and conda-build with the following command. 

    conda info 
**3. Add conda channels**
Software packages specified in recipe files must exist in conda channels. We recommend only use packages from `bioconda` and `conda-forge` channels.  To add channels, run the following commands

    conda config --add channels conda-forge
    conda config --add channels bioconda
You could also add desired channels by manually editing  `.condarc` file, located in your home folder `~/.condarc`. The .condarc file is not included by default, but it is automatically created in your home directory the first time you run the `conda config` command.

**4. Create Cellprofiler Recipe file**
Create meta.yaml file in recipe folder, for example `~/bcc2020/recipes/cellprofiler`
The recipe must reside under `recipes/cellprofiler` . You can rename '`cellprofiler`' with something else but the parent folder "`recipes`" can not be renamed.

    mkdir -p ~/bcc2020/recipes/cellprofiler
    cd ~/bcc2020/recipes/cellprofiler
    touch meta.yaml
Edit the recipe file. conda-forge provides an [example](https://github.com/conda-forge/staged-recipes/tree/master/recipes/example) template which you can use it to start developing recipes. 

The below recipe is an example for Cellprofiler3.1.9. For detailed documentation on defining the recipe file, please visit [here](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html)

    {% set name = "CellProfiler" %}
    {% set version = "3.1.9" %}
    
    package:
      name: "{{ name|lower }}"
      version: "{{ version }}"
    
    source:
      url: https://github.com/CellProfiler/{{ name  }}/archive/v{{ version }}.tar.gz
      sha256: "44e10c57980b4fd20f530dd5dc8c8bea9c870000601e12d500c27d145ca2ee9f"
    build:
      number: 3
      script: "{{ PYTHON }} -m pip install --no-deps --ignore-installed . -vv"
      skip: True  # [win]
      skip: True  # [osx]
    
    requirements:
      build:
        - {{ compiler('c') }}
      host:
        - python
        - pip
        - backports.functools_lru_cache
        - cython
        - openjdk 8.*
        - pytest
    
      run:
        - python
        - appdirs
        - boto3
        - centrosome
        - docutils
        - h5py
        - ipywidgets
        - inflect =2.1.0
        - joblib
        - jupyter
        - libtiff
        - libxml2
        - libxslt
        - lxml
        - packaging
        - pip
        - mahotas
        - matplotlib-base  >=2.0.0,!=2.1.0,<3
        - mysqlclient
        - numpy
        - javabridge
        - prokaryote
        - python-bioformats =1.5.2
        - pyzmq =15.3.0
        - raven
        - requests
        - scikit-image =0.14.*
        - scikit-learn >=0.20
        - scipy >=1.2
        - pillow
        - sphinx
        - tifffile
        - networkx ==2.2.*
        - vigra
        - future
    
    test:
      imports:
        - cellprofiler
    
    about:
      home: https://github.com/CellProfiler/CellProfiler
      license: 3-clause BSD
      license_family: BSD
      license_file: LICENSE
      summary: "CellProfiler is free, open-source software for quantitative analysis of biological images"
      description: |
         CellProfiler is free, open-source software for quantitative analysis of biological images.
    extra:
      recipe-maintainers:
        - sunyi000
**5. Create LICENSE file**
create a license file named "LICENSE" in the same folder where meta.yaml reside. This file is required if you want to contribute back to the Bioconda repository. Your recipe will only work locally without it. We recommend following the [Bioconda guideline] (https://bioconda.github.io/contributor/index.html)whenever your are developing your recipe.


**6. Build recipe into local channel**
go to the 'cellprofiler' folder created in Step 4. Run the below command

    conda build .

You can also build from the "recipes" folder

    conda build cellprofiler
**7. Create a conda environment**

    conda create -n cp319 python=2.7
if python=2.7 is not specified, conda will create an environment based on the python version on your host compute.

Activate the environment with 

    conda activate cp319

**8. Install from local channel**
Since we are installing Cellprofiler from local channel, we will need to specify in the `conda install` command 

    conda install --use-local cellprofiler
Once the installation finishes, Cellprofiler is then ready to be used.

## Test Cellprofiler Installation
1. Go to [https://cellprofiler.org/examples](https://cellprofiler.org/examples/) download an example Human Cell.
2. Make sure conda environment cp319 is activate.
3. Unzip and go to ExampleHuman folder
4. Create a folder "output" to store analysis output files
5. Run 

`cellprofiler -r -c -i images -p ExampleHuman.cppipe -o output`

If Cellprofiler installation was successful, you should see output files in the "`output`" folder.

## Contributing your recipe to Bioconda
If you would like to contribute your recipe back to Bioconda recipe, please follow the Bioconda guideline carefully. At Step 4 you will need to fork the Bioconda repository.  The basic workflow is 

 - Fork the official Bioconda recipe repository
 - Write a recipe or start with example template.
 - Push your recipe to GitHub. This triggers teh automatic building and testing of the recipe
 - Once tests passes, open a PR.  It will then be reviewed by other members of the Bioconda community.
 - If review is successful your recipe will then get merged into the master branch.

