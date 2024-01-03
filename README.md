![status](https://github.com/hpopp/kurpo-bot/actions/workflows/ci.yml/badge.svg)
[![version](https://img.shields.io/badge/version-0.5.1-orange.svg)](https://github.com/hpopp/kurpo-bot/commits/master)

# KurpoBot

This bot is terrible.

## Project Dependencies

This project requires these dependencies to be installed and running:

- Elixir 1.14.x
- Erlang 25.x
- Postgres 14.x

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

Unit tests can be run with `mix test` or `mix coveralls.html`.

### Formatting

This project uses Elixir's `mix format` for formatting. Add a hook in your editor of choice to
run it after a save. Be sure it respects this project's `.formatter.exs`.

### Commits

Git commit subjects use the [Karma style](http://karma-runner.github.io/5.0/dev/git-commit-msg.html).

## Deployment

Deployments require the following environment variables to be set in containers:

| Key               | Description                        | Required? | Default     |
| ----------------- | ---------------------------------- | --------- | ----------- |
| `DATABASE_URL`    | Database URL.                      | x         |             |
| `KURPO_ADMIN_IDS` | Administrator Discord user IDs.    |           | `1234`      |
| `KURPO_IDS`       | Discord user IDs to watch.         | x         |             |
| `KURPO_TOKEN`     | Discord bot token.                 | x         |             |
| `LOG_LEVEL`       | Logger level.                      |           | `error`     |
| `POD_IP`          | Host for Elixir release node name. |           | `127.0.0.1` |

## License

Copyright (c) 2021-2024 Henry Popp

This library is MIT licensed. See the [LICENSE](https://github.com/hpopp/kurpo-bot/blob/master/LICENSE) for details.
