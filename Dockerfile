FROM openjdk:17-jdk-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip \
        curl \
        libx11-6 libx11-dev libgl1-mesa-glx libgl1-mesa-dev \
        && rm -rf /var/lib/apt/lists/*

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O sdk.zip
RUN unzip sdk.zip -d /opt/
RUN rm sdk.zip
ENV ANDROID_HOME /opt/cmdline-tools
ENV PATH "$PATH:${ANDROID_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses > /dev/null

RUN sdkmanager --sdk_root="${ANDROID_HOME}" --install "platforms;android-33" "build-tools;33.0.2" "emulator" "system-images;android-33;google_apis;x86_64" "extras;android;m2repository" "platform-tools"

# Create AVD (Correct and improved method)
RUN mkdir -p /root/.android/avd/test_avd.avd && \
    echo "skin.path=_no_skin" > /root/.android/avd/test_avd.avd/config.ini && \
    avdmanager create avd --name test_avd --package "system-images;android-33;google_apis;x86_64" --abi x86_64 --force > /dev/null 2>&1 # Redirect output

WORKDIR /app