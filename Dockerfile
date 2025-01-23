# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-slim

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        curl \
        libx11-6 libx11-dev libgl1-mesa-glx libgl1-mesa-dev \
        libncurses5 libstdc++6 bash \
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
RUN chmod +x $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager
RUN ln -s $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager /usr/local/bin/sdkmanager

# Verify sdkmanager is working
RUN sdkmanager --version

# Accept all SDK licenses
RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses > /dev/null

# Install required Android components for Android 35 (update the system image version)
RUN sdkmanager --sdk_root="${ANDROID_HOME}" --install "system-images;android-35;google_apis;x86_64" \
    "extras;android;m2repository" "platform-tools"

# Set up necessary directories for the AVD and emulator
RUN mkdir -p ~/.android/avd && \
    touch ~/.android/repositories.cfg

# Debug step: List installed SDK components
RUN sdkmanager --list

# Set working directory
WORKDIR /app