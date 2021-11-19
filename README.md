# KurpoBot

This bot is terrible.

## Project Dependencies

This project requires these dependencies to be installed and running:

- Elixir 1.12.x
- Erlang 23.x
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
export KURPO_ID="userid"
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
