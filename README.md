[![CI](https://github.com/hpopp/kurpo-bot/actions/workflows/ci.yml/badge.svg)](https://github.com/hpopp/kurpo-bot/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/version-0.6.7-orange.svg)](https://github.com/hpopp/kurpo-bot/commits/main)
[![Last Updated](https://img.shields.io/github/last-commit/hpopp/kurpo-bot.svg)](https://github.com/hpopp/kurpo-bot/commits/main)

# KurpoBot

This bot is terrible.

## Project Dependencies

This project requires these dependencies to be installed and running:

- Elixir 1.18.x
- Erlang 27.x
- Postgres 16.x

## Getting Started

1. Clone the repository.

```shell
git clone https://github.com/hpopp/kurpo-bot && cd kurpo-bot
```

2. Fetch dependencies.

```shell
mix deps.get
```

3. Set your bot token, user ID, and admin user IDs.

```shell
export KURPO_ADMIN_IDS="userid1,userid2"
export KURPO_TOKEN="token"
export KURPO_IDS="userid1,userid2"
```

4. Run your database migrations.

```
mix ecto.create && mix ecto.migrate
```

5. Run the project.

```
iex -S mix
```

## Contributing

### Testing

Unit tests can be run with `mix test`.

### Formatting

This project uses Elixir's `mix format` for formatting. Add a hook in your editor of choice to
run it after a save. Be sure it respects this project's `.formatter.exs`.

### Commits

Git commit subjects use the [Karma style](http://karma-runner.github.io/5.0/dev/git-commit-msg.html).

## Deployment

Deployments require the following environment variables to be set in containers:

| Key                   | Description                                                  | Required? | Default     |
| --------------------- | ------------------------------------------------------------ | --------- | ----------- |
| `DATABASE_CACERTFILE` | Path to database CA certificate file for SSL connection.     |           |             |
| `DATABASE_CERTFILE`   | Path to database client certificate file for SSL connection. |           |             |
| `DATABASE_HOSTNAME`   | Database hostname for SSL certificate verification.          |           |             |
| `DATABASE_KEYFILE`    | Path to database client key file for SSL connection.         |           |             |
| `DATABASE_URL`        | Database URL.                                                | x         |             |
| `GCP_PROJECT_ID`      | GCP project identifier. Enables GCP formatted logging.       |           |             |
| `HEALTHCHECK_PORT`    | Server healthcheck port.                                     |           | `4321`      |
| `KURPO_ADMIN_IDS`     | Administrator Discord user IDs.                              |           | `1234`      |
| `KURPO_IDS`           | Discord user IDs to watch.                                   | x         |             |
| `KURPO_TOKEN`         | Discord bot token.                                           | x         |             |
| `LOG_LEVEL`           | Logger level.                                                |           | `info`      |
| `POD_IP`              | Host for Elixir release node name.                           |           | `127.0.0.1` |

### Liveness

A TCP liveness socket is available on port `HEALTHCHECK_PORT` (default 4321) in production releases.

### Configuring SSL for Database Connections

SSL is disabled by default unless `DATABASE_CACERTFILE` is defined. If set, `DATABASE_HOSTNAME`, `DATABASE_CERTFILE`,
and `DATABASE_KEYFILE` are also required. `DATABASE_HOSTNAME` should be set to the hostname specified in the CA
certificate, which could be different from the hostname in `DATABASE_URL` used in containerized or cloud environments.

## License

Copyright (c) 2021-2025 Henry Popp

This library is MIT licensed. See the [LICENSE](https://github.com/hpopp/kurpo-bot/blob/master/LICENSE) for details.
