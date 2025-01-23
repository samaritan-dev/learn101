# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-slim

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        curl \
        libx11-6 libx11-dev libgl1-mesa-glx libgl1-mesa-dev \
        && rm -rf /var/lib/apt/lists/*

# Set up Android SDK paths
ENV ANDROID_HOME /opt/android-sdk
ENV PATH "$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Download and extract Android command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools/latest && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O sdk.zip && \
    unzip sdk.zip -d $ANDROID_HOME/cmdline-tools/latest && \
    rm sdk.zip

# Move extracted tools to the correct directory
RUN mv $ANDROID_HOME/cmdline-tools/latest/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest/ && \
    rm -rf $ANDROID_HOME/cmdline-tools/latest/cmdline-tools

# Accept all SDK licenses
RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses > /dev/null

# Install required Android components
RUN sdkmanager --sdk_root="${ANDROID_HOME}" --install "emulator" "platform-tools" "system-images;android-33;google_apis;x86_64" \
    "extras;android;m2repository"

# Fetch the latest Android platform version dynamically and install it
RUN LATEST_PLATFORM=$(sdkmanager --list | grep "platforms;android-" | sort -V | tail -n 1 | awk '{print $1}') && \
    sdkmanager --sdk_root="${ANDROID_HOME}" --install "$LATEST_PLATFORM"

# Ensure necessary directories exist
RUN mkdir -p ~/.android/avd && \
    touch ~/.android/repositories.cfg

# Debug step: List installed SDK components
RUN sdkmanager --list

# Set working directory
WORKDIR /app