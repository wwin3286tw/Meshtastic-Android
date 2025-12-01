# Build Meshtastic-Android with Docker

This repository contains a Dockerfile and helper script to build Meshtastic-Android inside a container (so you don't need to install Android SDK or JDK on your host).

What this does:
- Creates an image with OpenJDK 21 and Android command-line tools
- Installs platform-tools, Android platform 36 and build-tools 36
- Builds the default F-Droid debug variant (safe to build without Google Maps API key)

Files added:
- `Dockerfile` — image definition
- `scripts/docker_build.sh` — helper script (builds image and runs Gradle inside the container)
- `.dockerignore` — keep build context lean

Quick start (from repository root):

```bash
# build and run assembleFdroidDebug (default)
./scripts/docker_build.sh :app:assembleFdroidDebug

# or build another target (e.g. Google debug)
./scripts/docker_build.sh :app:assembleGoogleDebug
```

Where to find the output:

- Artifacts are copied into `artifacts/outputs` relative to the repo root. Example:
  - `artifacts/outputs/apk/fdroid/debug/app-fdroid-debug.apk`

Notes & troubleshooting:
- The project includes a git submodule with protobuf definitions. If you cloned this repo yourself, clone recursively OR initialize submodules before building: `git submodule update --init --recursive`.
- If you need the `google` flavor, add your `MAPS_API_KEY` to `local.properties` (or pass it into the container) or otherwise set up Google service credentials.
- Builds can take a while on first run (downloads Gradle, SDK tools and dependencies). Subsequent builds are faster when the container or bind-mounted gradle cache is reused.
