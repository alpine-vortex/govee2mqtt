#!/bin/sh
# Build and publish the Govee2MQTT runtime and Home Assistant add-on locally.
#
# Prerequisite: `docker login ghcr.io` with a GitHub token that has write:packages.
# The script intentionally does not use GitHub Actions.

set -eu

REPO_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OWNER="${GITHUB_OWNER:-alpine-vortex}"
IMAGE="ghcr.io/${OWNER}/govee2mqtt"
SHORT_SHA="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
DOCKER_CONFIG_DIR="${DOCKER_CONFIG:-$HOME/.docker}"

git -C "$REPO_ROOT" fetch origin main --quiet
if [ "$(git -C "$REPO_ROOT" rev-parse HEAD)" != "$(git -C "$REPO_ROOT" rev-parse origin/main)" ]; then
  echo "Refusing to publish: HEAD must be the current origin/main tip." >&2
  exit 1
fi

if ! command -v cross >/dev/null 2>&1; then
  echo "Missing required Rust cross-compiler. Install it with: cargo install cross" >&2
  exit 1
fi

if [ ! -f "$DOCKER_CONFIG_DIR/config.json" ]; then
  echo "Missing Docker credentials at ${DOCKER_CONFIG_DIR}/config.json. Run: docker login ghcr.io" >&2
  exit 1
fi

build_target() {
  target="$1"
  echo "==> Building govee binary for ${target}"
  "$REPO_ROOT/scripts/build-cross.sh" "$target"
}

case ",$PLATFORMS," in
  *,linux/amd64,*) build_target linux/amd64 ;;
esac
case ",$PLATFORMS," in
  *,linux/arm64,*) build_target linux/arm64 ;;
esac

echo "==> Building and pushing runtime image: ${IMAGE}"
docker buildx build \
  --platform "$PLATFORMS" \
  --tag "${IMAGE}:latest" \
  --tag "${IMAGE}:${SHORT_SHA}" \
  --push \
  "$REPO_ROOT"

echo "==> Building and pushing Home Assistant add-on images"
docker run --rm --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$DOCKER_CONFIG_DIR/config.json:/root/.docker/config.json:ro" \
  -v "$REPO_ROOT/addon:/data" \
  ghcr.io/home-assistant/amd64-builder:latest \
  --amd64 \
  --aarch64 \
  --no-cosign-verify \
  --target /data

echo "==> Published ${IMAGE} and the architecture-specific add-on images"
