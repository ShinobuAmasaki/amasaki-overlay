# amasaki-overlay
Amasaki Shinobu's Public Overlay for Gentoo Linux.

## Usage

First, you have to install `app-eselect/eselect-repository`.

```shell
# emerge --ask app-eselect/eselect-repository
```

Next, add this repository by `eselect` command.

```shell
# eselect repository add amasaki-overlay git https://github.com/ShinobuAmasaki/amasaki-overlay.git
```

And then, sync your local repos.
```shell
# emerge --sync
```

## Available Packages

### sys-cluster/openpbs

[OpenPBS](https://github.com/openpbs/openpbs) -- An HPC workload manager and job scheduler for desktops, clusters, and clouds.


