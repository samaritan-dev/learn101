FROM ubuntu:latest

# Install required dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    unzip \
    wget \
    libgl1-mesa-dri \
    libxext6 \
    libxrender1 \
    libxi6 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Set up environment variables
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH

# Install Android command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip \
    && unzip -q cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools \
    && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm cmdline-tools.zip

# Accept licenses and install SDK components
RUN yes | sdkmanager --licenses \
    && sdkmanager --install "cmdline-tools;latest" "platforms;android-33" "system-images;android-33;google_apis;x86_64" "emulator" "platform-tools"

# Set up Android AVD
RUN mkdir -p ~/.android/avd \
    && echo "no" | avdmanager create avd -n test_emulator -k "system-images;android-33;google_apis;x86_64" --device "pixel_3a" --force

# Start the emulator
CMD nohup $ANDROID_HOME/emulator/emulator -avd test_emulator -no-window -no-audio -no-boot-anim -gpu swiftshader_indirect &