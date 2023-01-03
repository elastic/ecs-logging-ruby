ARG RUBY_IMAGE
FROM ${RUBY_IMAGE}

ARG USER_ID_GROUP
ARG FRAMEWORKS
ARG VENDOR_PATH
ARG BUNDLER_VERSION

RUN apt-get update -qq \
      && apt-get install -qq -y --no-install-recommends \
        build-essential libpq-dev git \
      && rm -rf /var/lib/apt/lists/*

# Configure bundler and PATH
ENV LANG=C.UTF-8

ENV GEM_HOME=$VENDOR_PATH
ENV BUNDLE_PATH=$GEM_HOME \
  BUNDLE_JOBS=4 BUNDLE_RETRY=3
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
  BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH=/app/bin:$BUNDLE_BIN:$PATH

ENV FRAMEWORKS $FRAMEWORKS
ENV RUBY_IMAGE $RUBY_IMAGE

# Copy cached folder to speed up docker containers
COPY vendor /vendor
RUN chown -R $USER_ID_GROUP /vendor
USER $USER_ID_GROUP

# Upgrade RubyGems and install required Bundler version
# https://github.com/rubygems/rubygems/issues/2534#issuecomment-448843746
RUN gem update --system --conservative || (gem i "rubygems-update:~>2.7" --no-document && update_rubygems) && \
      gem install bundler:$BUNDLER_VERSION --conservative

# Use unpatched, system version for more speed over less security
RUN gem install nokogiri -v 1.10.10 -- --use-system-libraries

WORKDIR /app

