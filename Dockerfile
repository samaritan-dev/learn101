# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-slim

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget unzip curl \
        libx11-6 libx11-dev libgl1-mesa-glx libgl1-mesa-dev \
        libstdc++6 libc6 libstdc++6 \
        && rm -rf /var/lib/apt/lists/*

# Set up Android SDK paths
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_AVD_HOME=/root/.android/avd
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Download and extract Android command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools/latest && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O sdk.zip && \
    unzip sdk.zip -d $ANDROID_HOME/cmdline-tools/latest && \
    rm sdk.zip

# Move extracted tools to the correct directory
RUN mv $ANDROID_HOME/cmdline-tools/latest/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest/ && \
    rm -rf $ANDROID_HOME/cmdline-tools/latest/cmdline-tools

# Ensure required directories exist
RUN mkdir -p ~/.android/avd && touch ~/.android/repositories.cfg

# Accept all SDK licenses
RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses > /dev/null

# Install required Android components
RUN sdkmanager --sdk_root="${ANDROID_HOME}" --install \
    "platforms;android-33" \
    "build-tools;33.0.2" \
    "emulator" \
    "system-images;android-33;google_apis;x86_64" \
    "extras;android;m2repository" \
    "platform-tools"

# Ensure sdkmanager and emulator are executable
RUN chmod +x $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager
RUN chmod +x $ANDROID_HOME/emulator/emulator

# Debug step: List installed SDK components
RUN sdkmanager --list

# Set working directory
WORKDIR /app

# Expose necessary ports for ADB & emulator UI
EXPOSE 5554 5555 5900

# Set up an AVD (Android Virtual Device) without hardware acceleration
RUN echo "no" | avdmanager create avd -n test_avd -k "system-images;android-33;google_apis;x86_64" --device "pixel"

# Start the emulator in software rendering mode (without KVM)
CMD ["emulator", "-avd", "test_avd", "-no-snapshot", "-no-audio", "-no-window", "-gpu", "swiftshader_indirect", "-accel", "off"]