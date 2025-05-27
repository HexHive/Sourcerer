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


## Artifact Evaluation

Instructions are available in [artifact.pdf](./artifact.pdf).

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
