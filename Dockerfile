FROM openjdk:17-jdk-slim

# Install necessary tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        curl \
        && rm -rf /var/lib/apt/lists/*

# Download and install Android SDK Command-line Tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O sdk.zip
RUN unzip sdk.zip -d /opt/
RUN rm sdk.zip
ENV ANDROID_HOME /opt/cmdline-tools
ENV PATH "$PATH:${ANDROID_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

# Set up Android SDK
RUN sdkmanager --sdk_root="${ANDROID_HOME}" \
    --install "platforms;android-33" \
    "build-tools;33.0.2" \
    "emulator" \
    "system-images;android-33;google_apis;x86" \
    "extras;android;m2repository" \
    --licenses --update

# Install ADB
RUN sdkmanager "platform-tools"

# Create an emulator (you can customize this)
RUN echo 'no' | avdmanager create avd -n "myEmulator" -k "system-images;android-33;google_apis;x86"

# Copy project files
COPY . /app

# Set working directory
WORKDIR /app

# Grant execute permission for gradlew
RUN chmod +x gradlew

# Build the project
CMD ["./gradlew", "assembleDebug"]