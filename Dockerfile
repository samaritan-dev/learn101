FROM openjdk:17-jdk-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        curl \
        && rm -rf /var/lib/apt/lists/*

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O sdk.zip
RUN unzip sdk.zip -d /opt/
RUN rm sdk.zip
ENV ANDROID_HOME /opt/cmdline-tools
ENV PATH "$PATH:${ANDROID_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

# Accept all licenses
RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses > /dev/null

RUN sdkmanager --sdk_root="${ANDROID_HOME}" --install "platforms;android-33" "build-tools;33.0.2" "emulator" "system-images;android-33;google_apis;x86_64" "extras;android;m2repository" "platform-tools"

RUN echo 'no' | avdmanager create avd -n "test_avd" -k "system-images;android-33;google_apis;x86_64"

WORKDIR /app