# Manual image publishing

This fork intentionally publishes images from a local machine, not GitHub Actions.

## Prerequisite

Authenticate Docker to GitHub Container Registry with a GitHub personal access token
that has the `write:packages` scope:

```sh
docker login ghcr.io
```

Install the Rust cross-compiler used to create the runtime binaries for each
target architecture:

```sh
cargo install cross
```

## Publish

From the repository root, run:

```sh
make publish
```

The command builds and pushes a multi-architecture runtime image to
`ghcr.io/alpine-vortex/govee2mqtt` and then builds/pushes the `amd64` and
`aarch64` Home Assistant add-on images defined by `addon/config.yaml`. It
cross-compiles each selected `govee` binary before Docker assembles its image.

To build only the architecture used by a particular Home Assistant host, set
`PLATFORMS` before running the script, for example:

```sh
PLATFORMS=linux/amd64 make publish
```

After a new image is published, Home Assistant detects the changed add-on
version from this repository and offers an update in the Add-on Store.
