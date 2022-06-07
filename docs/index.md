<!--
SPDX-FileCopyrightText: 2021 Magenta ApS <https://magenta.dk>
SPDX-License-Identifier: MPL-2.0
-->

# OS2mo Helm Chart

OS2mo Helm Chart is a <a href="https://helm.sh/">Helm</a> chart to deploy 
<a href="https://os2mo.readthedocs.io/">OS2mo</a>.

## Requirements

Helm 3+

## Installation & Usage

Assuming <a href="https://kubernetes.io/docs/tasks/tools/">`kubectl`</a> and
<a href="https://helm.sh/docs/intro/install/#helm">`helm`</a> are already installed
and <a href="https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/">cluster access is configured</a>:

```console
$ helm install mo os2mo/
$ helm install mo -f kind-override-values.yaml os2mo/
```

Which should bring up an OS2mo stack.

For a more detailed walk-through checkout the ["Getting Started"](GettingStarted.md) section.


## Development

We try to follow [best practices](https://helm.sh/docs/topics/charts/) as much
as possible, including defining structure on the chart values using [JSON
Schema](https://json-schema.org/) in the `values.schema.json` file.

For a proper development environment, you will need to install:

* [docker](https://docker.com/)
* [kind](https://kind.sigs.k8s.io/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* [helm](https://helm.sh/docs/intro/install/)
* [k9s](https://k9scli.io/)
* [flux](https://fluxcd.io/)
* [flux plugin for
  k9s](https://github.com/derailed/k9s/blob/master/plugins/flux.yml)

If you use NixOS, all of this is included in the `shell.nix` file in
`salt-automation`.

### First time setup

1. Start the cluster with `./start.sh`.
2. Look at the cluster with `k9s -A` until the cluster is ready
3. Run `helm install mo -f kind-override-values.yaml os2mo/` to install this
   chart

### Continually development

After making changes, you need to re-deploy the chart. This is done with:

`$ helm upgrade mo -f kind-override-values.yaml os2mo`

### Ingress

To test ingress, you will need to modify your `/etc/hosts`. The following
entries should provide a good basis:

```
127.0.0.1 os2mo.example.com
127.0.0.1 orgviewer-med.example.com
127.0.0.1 orgviewer-adm.example.com
```

### Teardown

To teardown the cluster completely, run `docker rm -vf CONTAINER_ID` on the
`kind` docker container. You can find the container ID with `docker ps`.


## License

This project is licensed under the terms of the MPL-2.0 license.
