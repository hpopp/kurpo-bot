FROM elixir:1.18-alpine AS builder

WORKDIR /kurpo-bot

ENV MIX_ENV=prod

RUN apk add --update --no-cache bash git openssh openssl

# Install mix dependencies.
COPY mix.exs mix.lock VERSION ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY lib lib

# Compile the release.
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

# Build release.
COPY rel rel
RUN mix release kurpo_bot

FROM alpine:3

ARG CREATED
ARG VERSION

LABEL org.opencontainers.image.authors="Henry Popp <henry@codedge.io>"
LABEL org.opencontainers.image.created="${CREATED}"
LABEL org.opencontainers.image.description="This bot is terrible."
LABEL org.opencontainers.image.documentation="https://github.com/hpopp/kurpo-bot"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/hpopp/kurpo-bot"
LABEL org.opencontainers.image.title="KurpoBot"
LABEL org.opencontainers.image.url="https://github.com/hpopp/kurpo-bot"
LABEL org.opencontainers.image.vendor="Henry Popp"
LABEL org.opencontainers.image.version="${VERSION}"

RUN apk add --update --no-cache bash git libstdc++ ncurses-libs openssl

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=builder --chown=nobody:nobody /kurpo-bot/dist/ ./

ENV HOME=/app
ENV MIX_ENV=prod

EXPOSE 4321

CMD ["bin/kurpo_bot", "start"]
