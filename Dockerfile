FROM ubuntu:14.04

# ------------------------------------------------------
# --- Environments and base directories

# Environments
# - Language
RUN locale-gen en_US.UTF-8
ENV LANG "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
# - Workspace
RUN mkdir /workspace
ENV WORKSPACE "/workspace"
# - Android-SDK
ENV ANDROID_HOME /opt/android-sdk-linux
# - Android-NDK
ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK /opt/android-ndk

# ------------------------------------------------------
# --- Base pre-installed tools
RUN apt-get update -qq
# Requiered
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git curl wget rsync sudo expect
# Common, useful
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install unzip
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install zip
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install tree
# For PPAs
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common


# Dependencies to execute Android builds
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-7-jdk libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME

RUN cd /opt && wget -q https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz -O android-sdk.tgz
RUN cd /opt && tar -xvzf android-sdk.tgz
RUN cd /opt && rm -f android-sdk.tgz

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# ------------------------------------------------------
# --- Install Android SDKs and other build packages

RUN echo y | android update sdk --no-ui --all --filter platform-tools
RUN echo y | android update sdk --no-ui --all --filter extra-android-support

# SDKs
RUN echo y | android update sdk --no-ui --all --filter android-23

# build tools
RUN echo y | android update sdk --no-ui --all --filter build-tools-23.0.3

# ------------------------------------------------------
# --- Install Gradle from PPA

# Gradle PPA
RUN add-apt-repository ppa:cwchien/gradle
RUN apt-get update
RUN apt-get -y install gradle
RUN gradle -v

# ------------------------------------------------------
# --- Android NDK

# For Native Android Projects
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y cmake ant

# download
RUN mkdir /opt/android-ndk-tmp
RUN cd /opt/android-ndk-tmp && wget -q http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
# uncompress
RUN cd /opt/android-ndk-tmp && chmod a+x ./android-ndk-r10e-linux-x86_64.bin
RUN cd /opt/android-ndk-tmp && ./android-ndk-r10e-linux-x86_64.bin
# move to it's final location
RUN cd /opt/android-ndk-tmp && mv ./android-ndk-r10e /opt/android-ndk
# remove temp dir
RUN rm -rf /opt/android-ndk-tmp
# add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}

# ------------------------------------------------------
# --- Cleanup, Workdir and revision

# Cleaning
RUN apt-get clean

WORKDIR $WORKSPACE

CMD bash