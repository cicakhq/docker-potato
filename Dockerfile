FROM lokedhs/sbcl-quicklisp:latest

RUN apt-get update && apt-get install -y git librabbitmq-dev libfixposix-dev libffi-dev gcc g++ nodejs nodejs-legacy

# Build the potato binary

RUN cd /root && \
    git clone https://github.com/cicakhq/potato && \
    cd potato && \
    git submodule init && \
    git submodule update && \
    tools/build_binary.sh

# Install lein

RUN cd /root && \
    wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
    chmod +x lein && \
    ./lein

# Compile cljs code

RUN cd /root/potato/web-app && \
    lein with-profile -dev cljsbuild once prod admin-prod

# CSS compilation

RUN npm install -g gulp && \
    npm install

RUN cd /root/potato/web-app && \
    gump build
