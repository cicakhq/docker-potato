FROM lokedhs/sbcl-quicklisp:latest

ENV POTATO_WORK /potato

RUN apt-get update && apt-get install -y git librabbitmq-dev libfixposix-dev openjdk-8-jdk libffi-dev gcc g++ nodejs nodejs-legacy npm

# Build the potato binary

WORKDIR $POTATO_WORK

RUN git clone https://github.com/cicakhq/potato && \
    cd potato && \
    git checkout 813f935b1ee0bc386055c65840f796da4bf14297 && \
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

RUN cd potato/web-app && \
    npm install -g gulp && \
    npm install

RUN cd potato/web-app && \
    gulp build
