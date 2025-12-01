FROM eclipse-temurin:21-jdk

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget unzip git curl ca-certificates build-essential libstdc++6 zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install command line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd /tmp && \
    # use a specific known commandline tools bundle; retry if network issues
    wget -q --tries=3 https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip || \
    wget -q --tries=3 https://dl.google.com/android/repository/commandlinetools-linux-latest.zip -O cmdline-tools.zip && \
    unzip -q cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm cmdline-tools.zip

# Accept licenses and install required SDK packages
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses >/dev/null || true
RUN sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "platforms;android-36" "build-tools;36.0.0" "ndk;25.2.9519653" || true

WORKDIR /workspace

COPY . /workspace

# Ensure the wrapper is executable
RUN chmod +x ./gradlew

# Default build target produces fdroid debug APK (safe for non-google builds)
CMD ["/bin/bash","-lc","./gradlew :app:assembleFdroidDebug --no-daemon -Dorg.gradle.jvmargs=\"-Xmx4g\""]
