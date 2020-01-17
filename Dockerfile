# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.8.1-alpine` image uses
ARG ALPINE_VERSION=3.9

FROM elixir:1.9-alpine AS builder

# The following are build arguments used to change variable parts of the image.
# The name of your application/release (required)
ARG APP_NAME=stone_bank

# The version of the application we are building (required)
ARG APP_VSN=0.1.0

# The environment to build with
ARG MIX_ENV=prod

# Set this to true if this release is not a Phoenix app
ARG SKIP_PHOENIX=false

# If you are using an umbrella project, you can change this
# argument to the directory the Phoenix app is in so that the assets
# can be built
ARG PHOENIX_SUBDIR=./apps/stone_bank_web

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV}

# By convention, /opt is typically used for applications
WORKDIR /opt/built

# This step installs all the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    alpine-sdk \
    coreutils \
    yarn \
    git && \
  mix local.rebar --force && \
  mix local.hex --force
    
# This copies our app source code into the build container
COPY . .

RUN mix deps.get && (cd deps/bcrypt_elixir && make clean && make) && mix do deps.compile, compile

RUN cd ${PHOENIX_SUBDIR}/assets && \
  yarn install && \
  yarn deploy && \
  cd .. && \
  mix phx.digest

RUN mix do release ${APP_NAME}

RUN cp -R _build/${MIX_ENV}/rel/${APP_NAME}/* /opt/built 

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:${ALPINE_VERSION}

# The name of your application/release (required)
ARG APP_NAME=stone_bank

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev      

ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME} \
    MIX_ENV=${MIX_ENV}

WORKDIR /opt/app

COPY --from=builder /opt/built .

EXPOSE 4000

CMD ["sh", "-c", "/opt/app/bin/${APP_NAME} eval 'StoneBank.ReleaseTasks.migrate';trap 'exit' INT; /opt/app/bin/${APP_NAME} start"]