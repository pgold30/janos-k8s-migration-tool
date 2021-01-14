# Janos

Welcome, time traveling soul… `janos` is a tool for Updating Kubernetes YAML configuration files.
It performs the steps required for a migration from K8s 1.15 to 1.16 
therefore can validate schemas for multiple versions of Kubernetes.

It has the following dependencies:
* [Yq](https://github.com/mikefarah/yq)
* [Kubeval](https://github.com/instrumenta/kubeval)


Janos performs 3 operations:
* Migration of deprecated APIs for K8s 1.16
* Generates field spec.selector which is required since 1.16  if it doesnt exist (it gets generated dinamically using matchLabels $app-name)
* Validate the resulting yaml for any K8s version using Kubeval

There is a dockerfile with all the dependecies [Here](https://hub.docker.com/r/pgold30/janos-k8s)

To install them on linux:
```
wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz && tar xf kubeval-linux-amd64.tar.gz && sudo cp kubeval /usr/local/bin
wget https://github.com/mikefarah/yq/releases/download/v4.3.2/yq_linux_amd64.tar.gz && tar xf yq_linux_amd64.tar.gz && mv yq_linux_amd64 /usr/local/bin/yq
```

For a story about this use case see [Story](https://medium.com/p/e2fd00cd8a2f/).
