# Protein Secondary Structure Predictor (PyTorch based)
This tutorial takes the reader to create a conda package from scratch, starting from a Python project.

## Pre-requisites
- Python >3.5
- conda
- conda-build


## [The Secondary Structure Prediction Project]:

The source code can be found on the GitHub repository: `https://github.com/vinclaveglia/secondary_structure_predictor_BCC2020`.
It is composed of several Python files and a trained neural network model ([slides](https://docs.google.com/presentation/d/12eNW0v6iDCdCr02oKMdDEh3rJWb_vtNlW4DxViavUKw))
.

It is necessary that a `setup.py` exists in order to package the project.


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
Create a structure folder as `/recipes/secondarystructurepredictor/`

Create the file `meta.yaml` and paste the following content:

```
{% set name = "SecondaryStructurePredictor" %}
{% set version = "0.1" %}

package:
  name: "{{ name|lower }}"
  version: "{{ version }}"

source:

  url: https://github.com/vinclaveglia/secondary_structure_predictor_BCC2020/archive/master.tar.gz
  

build:
  number: 0
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
    - secondaryStructurePredictor

extra:
  recipe-maintainers:
    - vinclaveglia
```


### 5. Build recipe into local channel
Go into the directory containing the `meta.yaml` and run:
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
Check the installed packages in the environment with `conda list`.

To uninstall the package, just type `conda uninstall secondarystructurepredictor`.

## Test the project
To test if the conda package installation was successful, open the Python shell and the following:
```
import secondaryStructurePredictor
import secondaryStructurePredictor.predict as p
p.test_prediction()
```
