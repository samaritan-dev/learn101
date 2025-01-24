# Use a base image with OpenJDK and Android SDK pre-installed
FROM ghcr.io/cirruslabs/android-sdk:33

# Set environment variables
ENV ANDROID_HOME /opt/android-sdk
ENV PATH $ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$PATH

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-dri \
    libxext6 \
    libxrender1 \
    libxi6 \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Accept Android SDK licenses
RUN yes | sdkmanager --licenses || true

# Install required SDK components
RUN sdkmanager --install \
    "platforms;android-33" \
    "system-images;android-33;google_apis;x86_64" \
    "emulator" \
    "platform-tools"

# Create an AVD
RUN mkdir -p $ANDROID_HOME/.android/avd && \
    echo "no" | avdmanager create avd -n test_emulator -k "system-images;android-33;google_apis;x86_64" --device "pixel_3a" --force

# Start the emulator automatically when the container starts
CMD ["sh", "-c", "nohup $ANDROID_HOME/emulator/emulator -avd test_emulator -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect -verbose & sleep 5 && adb wait-for-device && adb shell input keyevent 82 && tail -f /dev/null"]