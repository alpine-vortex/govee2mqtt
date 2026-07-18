# Govee to MQTT bridge for Home Assistant

This repo provides a `govee` executable whose primary purpose is to act
as a bridge between [Govee](https://govee.com) devices and Home Assistant,
via the [Home Assistant MQTT Integration](https://www.home-assistant.io/integrations/mqtt/).

## Features

* Robust LAN-first design. Not all of Govee's devices support LAN control,
  but for those that do, you'll have the lowest latency and ability to
  control them even when your primary internet connection is offline.
* Support for per-device modes and scenes.
* Support for the undocumented AWS IoT interface to your devices, provides
  low latency status updates.
* Support for the new [Platform
  API](https://developer.govee.com/reference/get-you-devices) in case the AWS
  IoT or LAN control is unavailable.

|Feature|Requires|Notes|
|-------|--------|-------------|
|DIY Scenes|API Key|Find in the list of Effects for the light in Home Assistant|
|Music Modes|API Key|Find in the list of Effects for the light in Home Assistant|
|Tap-to-Run / One Click Scene|IoT|Find in the overall list of Scenes in Home Assistant, as well as under the `Govee to MQTT` device|
|Live Device Status Updates|LAN and/or IoT|Devices typically report most changes within a couple of seconds.|
|Segment Color|API Key|Find the `Segment 00X` light entities associated with your main light device in Home Assistant|

* `API Key` means that you have [applied for a key from Govee](https://developer.govee.com/reference/apply-you-govee-api-key)
  and have configured it for use in govee2mqtt
* `IoT` means that you have configured your Govee account email and password for
  use in govee2mqtt, which will then attempt to use the
  *undocumented and likely unsupported* AWS MQTT-based IoT service
* `LAN` means that you have enabled the [Govee LAN API](https://app-h5.govee.com/user-manual/wlan-guide)
  on supported devices and that the LAN API protocol is functional on your network

## Usage

* [Installing the HASS Add-On](docs/ADDON.md) - for HAOS and Supervised HASS users
* [Running it in Docker](docs/DOCKER.md)
   * [Configuration](docs/CONFIG.md)

## Why this fork exists

This is the personally maintained Home Assistant deployment of Govee2MQTT for
the `alpine-vortex` household. It exists to keep a reliable working bridge
while preserving an older installation as a fallback.

The fork is based on the compatibility work in `miller79/govee2mqtt`, which
restored the account-login behavior needed for the affected Govee service
changes. It also adds explicit support for the H7175 Gooseneck Kettle, exposing
power, current temperature, target temperature, modes, and mode presets in
Home Assistant.

## What changed

* The Home Assistant repository and published images are owned by
  [`alpine-vortex/govee2mqtt`](https://github.com/alpine-vortex/govee2mqtt).
* The H7175 kettle is mapped as a kettle device instead of appearing only as
  diagnostics.
* Images are built and published manually from a trusted local machine; this
  fork does not use GitHub Actions for image publishing.
* The runtime image and both architecture-specific Home Assistant images are
  public GHCR packages so Home Assistant can install and update the App.
* The current Home Assistant App comes from this repository. The previous
  Miller fork is intentionally retained, stopped, and configured for manual
  start as a fallback.

## How it was set up

1. Add `https://github.com/alpine-vortex/govee2mqtt` in Home Assistant under
   **Settings → Apps → App Store → Repositories**.
2. Install the Govee to MQTT Bridge from this repository as a separate App.
3. Copy the Govee and MQTT options from the working fallback App.
4. Stop the fallback App before starting this one; both must not publish the
   same MQTT discovery entities at the same time.
5. Keep the fallback App set to manual start.

## Maintaining this fork

See [manual publishing](docs/MANUAL_PUBLISH.md) for the detailed publishing
workflow. In short:

1. Make and test a change on a branch, then merge it into `main`.
2. Bump `version` in `addon/config.yaml` before every published release. Home
   Assistant detects updates from this version; republishing an unchanged
   version will not create an App update.
3. On a trusted Linux machine with Docker/Buildx, Rust, `cross`, and a GHCR
   login authorized with `write:packages`, update your local `main` and run:

   ```sh
   make publish
   ```

   The publish script requires the local checkout to be exactly at
   `origin/main`, cross-compiles `amd64` and `arm64` binaries, publishes the
   multi-architecture runtime image, and then publishes the `amd64` and
   `aarch64` Home Assistant images.

4. Keep these GHCR packages public: `govee2mqtt`, `govee2mqtt-amd64`, and
   `govee2mqtt-aarch64`. Home Assistant cannot use the publisher's local
   Docker credentials to pull private images.
5. Review upstream changes deliberately before merging them; preserve the
   H7175 mapping and the manual publishing setup when resolving conflicts.

## Reverting safely

The fallback App is the fast rollback path:

1. Stop the `alpine-vortex` Govee to MQTT Bridge App.
2. Start the stopped Miller-fork Govee to MQTT Bridge App.
3. Confirm that the Govee entities return and that only one bridge is running.

Do not remove the fallback App or its configuration until the replacement has
been stable for a while. To roll back a code change in this repository, revert
the corresponding commit or pull request, bump `addon/config.yaml` to a new
version, publish again, and apply the offered Home Assistant update.

## Have a question?

* [Is my device supported?](docs/SKUS.md)
* [Check out the FAQ](docs/FAQ.md)

## Want to show your support or gratitude?

It takes significant effort to build, maintain and support users of software
like this. If you can spare something to say thanks, it is appreciated!

* [Sponsor me on Github](https://github.com/sponsors/wez)
* [Sponsor me on Patreon](https://patreon.com/WezFurlong)
* [Sponsor me on Ko-Fi](https://ko-fi.com/wezfurlong)
* [Sponsor me via liberapay](https://liberapay.com/wez)

## Credits

This work is based on my earlier work with [Govee LAN
Control](https://github.com/wez/govee-lan-hass/).

The AWS IoT support was made possible by the work of @bwp91 in
[homebridge-govee](https://github.com/bwp91/homebridge-govee/).
