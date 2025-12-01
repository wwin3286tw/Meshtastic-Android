#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/docker_build.sh [gradle task]
# Default: :app:assembleFdroidDebug

TASK=${1:-":app:assembleFdroidDebug"}

IMAGE_NAME=meshtastic-android-build:latest
PROJECT_DIR=$(cd "$(dirname "$0")/.." && pwd)

echo "Building Docker image ${IMAGE_NAME}..."
docker build -t ${IMAGE_NAME} -f ${PROJECT_DIR}/Dockerfile ${PROJECT_DIR}

ARTIFACTS_DIR=${PROJECT_DIR}/artifacts
mkdir -p ${ARTIFACTS_DIR}

echo "Running build inside container (task=${TASK})..."
docker run --rm -v ${PROJECT_DIR}:/workspace -v /tmp/gradle-cache:/root/.gradle -e VERSION_NAME="local" ${IMAGE_NAME} /bin/bash -lc "./gradlew ${TASK} --no-daemon -Dorg.gradle.jvmargs='-Xmx4g'"

echo "Copying artifacts to: ${ARTIFACTS_DIR}"
cp -R ${PROJECT_DIR}/app/build/outputs ${ARTIFACTS_DIR} || true

echo "Done. Output (if any) available in ${ARTIFACTS_DIR}"
