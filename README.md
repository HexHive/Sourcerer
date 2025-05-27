[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://github.com/llvm/llvm-project/blob/release/19.x/LICENSE.TXT)


# Sourcerer: Channeling the void

The rest of this document will walk you trough replicating the results from our [paper](https://hexhive.epfl.ch/publications/files/25DIMVA.pdf):
[`Sourcerer Channeling the void`](https://hexhive.epfl.ch/publications/files/25DIMVA.pdf) published in DIMVA'25.

### Citation
```

@inproceedings{Badoux_sourcerer_2025,
  author = {Badoux, Nicolas and Toffalini, Flavio and Payer, Mathias},
  month = jul,
  booktitle={International Conference on Detection of Intrusions and Malware, and Vulnerability Assessment},
  title = {{Sourcerer: Channelling the void}},
  year = {2025}
}
```

### Repository layout
The repository is originally a fork of LLVM 19.0.0. The code of Sourcerer is commited
in the respective folder of the LLVM project ([clang](./clang), [LLVM](./llvm),
etc...).  Lastly, in the [Type++](./Type++/) folder, you can find all the
scripts to run the different experiments. 

- For SPEC CPU:
[patches](./Type++/spec_cpu/patch), [scripts to run the
experiments](./Type++/spec_cpu/run.py), and [get the results](./Type++/script/).


The LLVM code is released under the Apache License v2.0 with LLVM Exceptions. The type++ code follows the same license. 


## Artifact

Instructions are available in [artifact.pdf](./artifact.pdf).

The artifact contains the material to reproduce the results:

- **Porting Effort** (Section 7.1 – Table 1)
- **Performance Overhead** (Section 7.2 – Table 2)
- **Source of Performance Overhead** (Section 7.3 – Table 3)
- **Sourcerer as a Sanitizer for Fuzzing Campaigns** (Section 7.4 – Figure 1)

This material is released under the Apache License 2.0, in line with the LLVM project Sourcerer builds upon.

**1. Accessing the artifact**:  
We release the artifact on a [public GitHub repository](https://github.com/HexHive/Sourcerer). The `main` branch contains the latest version of the code.

**2. Hardware dependencies**:
- Minimum: 16GB RAM for SPEC CPU evaluations
- Recommended: 128GB RAM and 1TB disk

**3. Software dependencies**:
- Ubuntu 20.04
- Docker
- Active internet connection (for Chromium evaluation)
- Installed: `curl`, `git`, `docker`, `pip`

**4. Benchmarks**:
- SPEC CPU 2006 and 2017 benchmarks ([SPEC CPU 2006](https://www.spec.org/cpu2006/), [SPEC CPU 2017](https://www.spec.org/cpu2017/))

### Artifact Installation

Clone the repository and build the Docker image:

```bash
REPO=https://github.com/HexHive/Sourcerer
git clone $REPO --single-branch --branch main --depth 100 Sourcerer
cd Sourcerer
pip install -r requirements.txt
```

Each experiment is encapsulated in Docker containers. The \`Dockerfile\` is at the root of the repository. We do not provide support for running experiments outside Docker.

### Experiment Workflow

The artifact reproduces results from four experiments:

1. **Compatibility** (extra classes to instrument over type++)
2. **Performance Overhead** (SPEC CPU 2006 and 2017)
3. **Ablation Study** (source of overhead)
4. **Fuzzing Campaign** (on OpenCV)

Scripts are provided to run experiments and generate the corresponding tables and figure. More details are in the repository’s \`README.md\`.

### Major Claims

- **(C1) Compatibility**:  
  Sourcerer is compatible with C++ codebases with minor changes.  
  → See Experiment E1, Table 1.

- **(C2) Performance Overhead**:  
  Sourcerer introduces negligible overhead while adding protection.  
  → See Experiment E2, Table 2.

- **(C3) Ablation Study**:  
  Overhead analysis of Sourcerer’s components.  
  → See Experiment E3, Table 3.

- **(C4) Fuzzing Campaign**:  
  Demonstrates Sourcerer in a fuzzing context.  
  → See Experiment E4, Figure 1.

### Evaluation

#### Experiment 1 (E1) - Compatibility Analysis

**[2 minutes human + 2 compute-hours]**

Evaluate extra classes in SPEC CPU benchmarks.

##### Preparation:
Ensure both `.iso` benchmark files are in the repository root.

##### Execution:
```bash
./table1.sh
```

##### Output:
Logs and a table similar to Table 1.

---

#### Experiment 2 (E2) - Performance Overhead

**[2 minutes human + 15 compute-hours]**

Compare SPEC CPU performance with/without cast checking (Sourcerer vs LLVM-CFI).

##### Preparation:
Ensure both `.iso` benchmark files are in the repository root.

##### Execution:
```bash
./table2.sh
```

##### Output:
Logs and a table similar to Table 2. Expect ~10% variation in performance.

---

#### Experiment 3 (E3) - Ablation Study

**[2 minutes human + 15 compute-hours]**

Measure cost of individual components in the type checking process.

##### Preparation:
Ensure both `.iso` benchmark files are in the repository root.

##### Execution:
```bash
./table3.sh
```

##### Output:
Table similar to Table 3.

---

#### Experiment 4 (E4) - Fuzzing Campaign

**[2 minutes human + 25 compute-hours]**

Compare Sourcerer and ASan in a fuzzing campaign on OpenCV.

##### Preparation:
```bash
./fig1_requirements.sh
```

##### Execution:
```bash
./fig1.sh
```

##### Output:
Figures similar to Figure 1, saved in `fuzzing_pics`.

## Usage

Todo


## Troubleshooting

### Disk space issue

The different Docker images require quite some space. If you run out of space,
you can remove specific container with `docker rm $CONTAINER_ID` or run [`docker
system prune`](https://docs.docker.com/reference/cli/docker/system/prune/) which
removes dangling images and containers. This might, however, require to rebuild
some images via the respective `docker build` command. 

### Container name already in use

If you want to rerun the evaluation, you will first need to remove the named
containers as the name has to be unique. Simply execute `docker rm
$CONTAINER_NAME` before relaunching the evaluation. If the evaluation was is
still running, first kill the container via `docker kill $CONTAINER_NAME`.

### Permission issue inside the Docker container

The whole artifact folder is mounted inside the Docker containers. Any
modification to the permissions of the folder will be reflected inside the
container. In particular, if the owner of the folder is changed, the ID inside
the container will not match the owner of the files resulting in permission
issues.  If you encounter this problem, you should reset the permissions inside
the container with the `chown -R $USER:$USER` command. To access inside the
container, you can use the `docker exec -it $CONTAINER_ID zsh` command.
