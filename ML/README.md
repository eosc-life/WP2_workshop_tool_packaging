# Protein Secondary Structure Predictor (PyTorch based)
This tutorial takes the reader to create a conda package from scratch, starting from a python project.

## Pre-requisites
- Python >3.5
- conda
- conda-build

## Files
elenco dei file che servono

## [The Secondary Structure Prediction Project]:
The project stands on the github repository: `https://github.com/vinclaveglia/bcc_2020_packaging`.
It is composed of several Python files and a trained neural network model.

It is necessary that a `setup.py` exists in the project. It is necessary to package the project.



## [Conda steps]:
### 1. Install conda
A resource [here](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html).

### 2. Install conda-build
```
conda install conda-build
```
### 3. Add conda channels
```
conda config --add channels conda-forge
```
To show the associated channels, run:
```
conda config --show channels
```
### 4. Add the recipe file
Create a structure folder as /recipes/secondarystructurepredicto/ ???

Create the file `meta.yaml` and paste the following content.

```
{% set name = "SecondaryStructurePredictor" %}
{% set version = "0.1" %}

package:
  name: "{{ name|lower }}"
  version: "{{ version }}"

source:
  #url: https://github.com/vinclaveglia/secondary_structure_prediction/archive/master.zip
  url: https://github.com/vinclaveglia/bcc_2020_packaging/archive/master.tar.gz
  #url: https://github.com/vinclaveglia/bcc_2020_packaging/blob/master/dist/SecondaryStructurePredictor-0.1dev.tar.gz


build:
  number: 0
  # out tool is pure python and do not need to be installed.
  script: "{{ PYTHON }} -m pip install --no-deps --ignore-installed . -vv"



requirements:
  host:
    - python
  run:
    - python
    - pytorch-cpu
    - scikit-learn >=0.20

test:
  import:
    - SecondaryStructurePredictor

  #source_files:
  #  - struc_classifier_SD2_0.7907
  #  - predict.py
  #  - secStructPredictor.py
    #- run_test.py

  #commands:
  #  - python predict.py "AAAA"


extra:
  recipe-maintainers:
    - vinclaveglia
```


### 5. Build recipe into local channel
Go into the directory containing the meta.yaml and run:
```
conda build .
```
Now the package exists and is in a local conda channel.

### 6. Create a new (empty) conda environment
```
conda create --name secPredEnv
```

### 7. Activate conda environment
```
conda activate secPredEnv
```


### 8. Install from local channel
```
conda install --use-local secondarystructurepredictor
```
and check the installed packages in the environment with `conda list`.

To uninstall the package, just type `conda uninstall secondarystructurepredictor`.

## Test the project
To test if the conda package installation was successful, open the python shell and the following:
```
import secondaryStructurePredictor
import secondaryStructurePredictor.predict as p
p.test_prediction()
```
