FROM lokedhs/sbcl-quicklisp:latest

ENV POTATO_WORK /potato

RUN apt-get update && apt-get install -y git librabbitmq-dev libfixposix-dev openjdk-8-jdk libffi-dev gcc g++ nodejs nodejs-legacy npm imagemagick

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
    git checkout f4d10b1961117e93296290d6e6f9fcc0e231795c && \
    git submodule init && \
    git submodule update && \
    tools/build_binary.sh

# Install lein

RUN wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
    chmod +x lein && \
    ./lein

# Compile cljs code

RUN cd potato/web-app && \
    $POTATO_WORK/lein with-profile -dev cljsbuild once prod admin-prod

# CSS compilation

USER root
ENV HOME /root
RUN cd potato/web-app && \
    npm install -g gulp
USER potato
ENV HOME $POTATO_WORK

RUN cd potato/web-app && \
    npm install

RUN cd potato/web-app && \
    gulp build

USER root
ENV HOME /root
