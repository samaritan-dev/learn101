# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-slim

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        curl \
        libx11-6 libx11-dev libgl1-mesa-glx libgl1-mesa-dev \
        libncurses5 libstdc++6 \
        && rm -rf /var/lib/apt/lists/*

# Set up Android SDK paths
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK_ROOT $ANDROID_HOME
ENV PATH "$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Download and extract Android command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools/latest && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O sdk.zip && \
    unzip sdk.zip -d $ANDROID_HOME/cmdline-tools/latest && \
    rm sdk.zip

# Ensure sdkmanager is available
RUN ln -s $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager /usr/local/bin/sdkmanager

# Accept all SDK licenses
RUN yes | /usr/local/bin/sdkmanager --sdk_root="${ANDROID_HOME}" --licenses > /dev/null

# Install required Android components
RUN sdkmanager --sdk_root="${ANDROID_HOME}" --list | grep "system-images" | tail -n 1 | \
    awk -F ';' '{print "system-images;"$1";google_apis;x86_64"}' > latest_platform.txt

# Extract the latest system image package
RUN LATEST_PLATFORM=$(cat latest_platform.txt) && \
    sdkmanager --sdk_root="${ANDROID_HOME}" --install "$LATEST_PLATFORM" "extras;android;m2repository" "platform-tools"

# Set up necessary directories for the AVD and emulator
RUN mkdir -p ~/.android/avd && \
    touch ~/.android/repositories.cfg

# Debug step: List installed SDK components
RUN sdkmanager --list

# Set working directory
WORKDIR /app

# Install curl (for fetching latest platform dynamically) and tools
RUN apt-get update && apt-get install -y curl