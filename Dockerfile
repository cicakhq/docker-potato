FROM lokedhs/sbcl-quicklisp:latest

ENV POTATO_WORK /potato

RUN apt-get update && apt-get install -y git librabbitmq-dev libfixposix-dev openjdk-8-jdk libffi-dev gcc g++ nodejs nodejs-legacy npm imagemagick curl unzip sassc

# Create the user

RUN useradd -m potato
RUN mkdir $POTATO_WORK && chown potato $POTATO_WORK

# Copy the QL installation from root's home directory
RUN cp -r /root/quicklisp $POTATO_WORK && \
    chown -R potato $POTATO_WORK/quicklisp && \
    cp /root/.sbclrc $POTATO_WORK && \
    chown potato $POTATO_WORK/.sbclrc

# Use the potato user

USER potato
ENV HOME $POTATO_WORK

# Build the potato binary

WORKDIR $POTATO_WORK

RUN git clone https://github.com/cicakhq/potato && \
    cd potato && \
    git checkout 05d621148002c413409eb1b704f3897b8adcf9be && \
    git submodule init && \
    git submodule update

RUN cd potato && \
    tools/build_binary.sh

# Install lein

RUN wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
    chmod +x lein && \
    ./lein

# Compile cljs code

RUN cd potato/web-app && \
    $POTATO_WORK/lein with-profile -dev cljsbuild once prod admin-prod

# CSS compilation

USER potato
RUN cd potato/web-app && \
    ./make.sh

USER root
ENV HOME /root
