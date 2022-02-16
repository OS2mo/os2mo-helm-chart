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
$ helm install chart/ --generate-name
```

Which should bring up an OS2mo stack.

For a more detailed walk-through checkout the ["Getting Started"](docs/GettingStarted.md) section.

## License

This project is licensed under the terms of the MPL-2.0 license.
