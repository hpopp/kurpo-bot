FROM elixir:1.16-alpine as builder

WORKDIR /kurpo-bot

ARG VERSION

ENV MIX_ENV prod

RUN apk add --update --no-cache bash git openssh openssl
RUN mix do local.hex --force, local.rebar --force

COPY mix.exs mix.lock VERSION ./
COPY config config
COPY priv priv
COPY rel rel
COPY lib lib
RUN mix do deps.get, deps.compile

RUN mix release kurpo_bot

FROM alpine:3

RUN apk add --update --no-cache bash git libstdc++ ncurses-libs openssl

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=builder --chown=nobody:nobody /kurpo-bot/dist/ ./

ENV MIX_ENV prod
ENV HOME=/app

CMD ["bin/kurpo_bot", "start"]
