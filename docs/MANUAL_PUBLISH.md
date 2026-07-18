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

The repository selects Cross's current maintained builder images automatically.
This avoids a glibc mismatch with current Rust toolchains.

## Publish

From the repository root, run:

```sh
make publish
```

The command builds and pushes a multi-architecture runtime image to
`ghcr.io/alpine-vortex/govee2mqtt` and then builds/pushes the `amd64` and
`aarch64` Home Assistant add-on images defined by `addon/config.yaml`. It
cross-compiles each selected `govee` binary before Docker assembles its image.
The add-on build uses Home Assistant's current Builder image. That deprecated
local Builder currently expects a signature that its official base images no
longer publish, so the publisher disables only that Builder-side verification
(`--no-cosign-verify`).
The base images are still pulled directly from `ghcr.io/home-assistant`.
The read-only Docker credential file is passed to the Builder so it can pull
this fork's private runtime image from GHCR while retaining a writable local
Buildx cache.

To build only the architecture used by a particular Home Assistant host, set
`PLATFORMS` before running the script, for example:

```sh
PLATFORMS=linux/amd64 make publish
```

After a new image is published, Home Assistant detects the changed add-on
version from this repository and offers an update in the Add-on Store.
