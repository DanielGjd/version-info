FROM node:16.17.0-buster as base

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG http_proxy=${HTTP_PROXY}
ARG https_proxy=${HTTPS_PROXY}

ARG FILE_IAV_SSH_PRIVATEKEY
ARG FILE_IAV_SSH_PUBLICKEY

ARG DEVSTACK_JFROG_HOST
ARG DEVSTACK_JFROG_API_KEY
ARG DEVSTACK_JFROG_EMAIL
ARG DEVSTACK_JFROG_USERNAME
ARG FILE_NPM_JFROG_CONFIGURATION

ENV JFROG_HOST $DEVSTACK_JFROG_HOST
ENV JFROG_API_KEY $DEVSTACK_JFROG_API_KEY
ENV JFROG_EMAIL $DEVSTACK_JFROG_EMAIL
ENV JFROG_USERNAME $DEVSTACK_JFROG_USERNAME

RUN apt-get update && apt-get install --yes --no-install-suggests \
    zip \
    unzip \
    # dependencies for Puppeteer
    # (see https://github.com/puppeteer/puppeteer/blob/master/docs/troubleshooting.md#chrome-headless-doesnt-launch-on-unix)
    # install-recommends is needed for correct installation of dependencies for puppeteer
      ca-certificates \
      fonts-liberation \
      gconf-service \
      libappindicator1 \
      libasound2 \
      libatk-bridge2.0-0 \
      libatk1.0-0 \
      libc6 \
      libcairo2 \
      libcups2 \
      libdbus-1-3 \
      libexpat1 \
      libfontconfig1 \
      libgbm1 \
      libgcc1 \
      libgconf-2-4 \
      libgdk-pixbuf2.0-0 \
      libglib2.0-0 \
      libgtk-3-0 \
      libnspr4 \
      libnss3 \
      libpango-1.0-0 \
      libpangocairo-1.0-0 \
      libstdc++6 \
      libx11-6 \
      libx11-xcb1 \
      libxcb1 \
      libxcomposite1 \
      libxcursor1 \
      libxdamage1 \
      libxext6 \
      libxfixes3 \
      libxi6 \
      libxrandr2 \
      libxrender1 \
      libxss1 \
      libxtst6 \
      lsb-release \
      wget \
      xdg-utils \
      # used for cypress
      xvfb \
      xauth \
      libasound2 \
      libnotify-dev \
      libgbm-dev \
      libgtk2.0-0 \
  && rm -rf /var/lib/apt/lists/* \
  # create ssh folder
  && mkdir -p ~/.ssh \
  # disable usage of known_hosts
  && git config --global core.sshCommand "ssh -o StrictHostKeyChecking=no" \
  # install ssh access
  && cp -rf $FILE_IAV_SSH_PRIVATEKEY ~/.ssh/id_ed25519 \
  && cp -rf $FILE_IAV_SSH_PUBLICKEY ~/.ssh/id_ed25519.pub \
  # ensure the newline after key data to suppress errors
  && echo >> ~/.ssh/id_ed25519 \
  && echo >> ~/.ssh/id_ed25519.pub \
  # install basic npm configuration
  && cp -rf $FILE_NPM_JFROG_CONFIGURATION ~/.npmrc \
  # add git redirection rule to ssh
  && git config --global url.ssh://git@vw.gitlab.iav.com:2201/.insteadof git://vw.gitlab.iav.com:2201/ \
  # limit access rights, otherwise git will refuse the connection
  && chmod -R 700 ~/.ssh

# https://superuser.com/questions/1420660/docker-container-ssh-error-ssh-exchange-identification-connection-closed-by-re
# fix problem, that the ssh-deamon is not running sporadically when the immage is reused
CMD ["/usr/sbin/sshd", "-D"]

# Install chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get install -y google-chrome-stable

WORKDIR /build

# ---------------- image stage for local builds
FROM base as dev

# ---------------- image stage for ci builds
FROM base as ci

WORKDIR /dockerbuild

ADD package.json ./
ADD package-lock.json ./

# See https://docs.npmjs.com/cli/ci.html, why to use `npm ci` and not `npm install`
# This is done to test if the package-lock.json is valid. In case of npm ci issues
# the very first step, creating the docker container, will fail immediately.
RUN npm config set _password $JFROG_API_KEY \
    && npm config set email $JFROG_EMAIL \
    && npm config set username $JFROG_USERNAME \
    && npm config set //$JFROG_HOST:_password $JFROG_API_KEY \
    && npm config set //$JFROG_HOST:email $JFROG_EMAIL \
    && npm config set //$JFROG_HOST:username $JFROG_USERNAME \
    && npm ci --verbose \
    && ls -la \
    && rm -Rf node_modules

WORKDIR /build

