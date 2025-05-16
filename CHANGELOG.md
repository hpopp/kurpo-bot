# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.5] - 2025-05-16

### Added

- Configure TCP liveness socket port with `HEALTHCHECK_PORT` environment variable. Still defaults
  to 4321. [#20](https://github.com/hpopp/kurpo-bot/pull/20)
- Improved type documentation. [#20](https://github.com/hpopp/kurpo-bot/pull/20)

## [0.6.4] - 2025-05-03

### Added

- TCP liveness socket now available on port 4321. [#19](https://github.com/hpopp/kurpo-bot/pull/19)
- Better OpenContainer labels for the Docker image. [#19](https://github.com/hpopp/kurpo-bot/pull/19)

## [0.6.3] - 2025-03-04

### Fixed

- Removed runtime warning for unused ffmpeg. [#18](https://github.com/hpopp/kurpo-bot/pull/18)

## [0.6.2] - 2025-02-22

### Added

- Fetch and persist channel information during scrape. This is used to persist a channel's `guild_id`,
  which has now been dropped from the API response to fetch channel messages. [#16](https://github.com/hpopp/kurpo-bot/pull/16)

### Fixed

- Removed runtime warnings for unused dependencies. [#17](https://github.com/hpopp/kurpo-bot/pull/17)
- Updated deprecated Nostrum functions. [#17](https://github.com/hpopp/kurpo-bot/pull/17)

## [0.6.1] - 2024-11-28

### Added

- Enable GCP formatted logging by setting `GCP_PROJECT_ID` environment variable.
- Better logging statements with metadata.

## [0.6.0] - 2024-11-22

### Added

- Support for SSL database connections with new environment variables:
  - `DATABASE_CACERTFILE`
  - `DATABASE_CERTFILE`
  - `DATABASE_KEYFILE`
  - `DATABASE_HOSTNAME`

### Changed

- Default `LOG_LEVEL` set to `info`.

## [0.5.6] - 2024-09-06

### Changed

- Updated to Elixir 1.17/OTP 27.
- Updated dependencies.

## [0.5.5] - 2024-05-18

### Added

- Updated various documentation and typespecs.

### Changed

- Updated dependencies.

### Removed

- Removed unused `KurpoBot.MessageStore`.

## [0.5.4] - 2024-01-09

### Fixed

- Updated author Discord handle in `!info`.

## [0.5.3] - 2024-01-07

### Fixed

- `storytime` and `ping` now made case-insensitive.

## [0.5.2] - 2024-01-02

### Changed

- Updated dependencies.
- Updated LICENSE copyright year.

## [0.5.1] - 2023-11-13

### Fixed

- Use latest Nostrum master for Discord http/2 fix.

## [0.5.0] - 2023-10-06

### Added

- OpenTelemetry to export telemetry.

### Changed

- Upgraded dependencies: ecto_sql 3.10.3, postgrex 0.17.3, ssl_verify_fun: 1.1.7

## [0.4.0] - 2023-05-13

### Added

- `@KurpoBot ping` to request a message with a ping.

## [0.3.2] - 2023-03-13

### Fixed

- Remove random print statement from logs.

## [0.3.1] - 2022-12-30

### Fixed

- Reply messages work again.

## [0.3.0] - 2022-12-30

### Added

- Support multiple Kurpo IDs. All configured IDs are watched and random messages
  can be taken from any of them.

### Changed

- `KURPO_ID` renamed to `KURPO_IDS`, now a comma-separated list like `KURPO_ADMIN_IDS`.

## [0.2.1] - 2022-12-26

### Fixed

- Properly declare priviledged message_content intent.

### Changed

- Updated dependencies.
- Updated author Discord handle.
- `POD_IP` environment variable now defaults to `127.0.0.1` when not specified.

## [0.2.0] - 2021-11-26

### Added

- `@KurpoBot storytime` for a list of five messages randomly selected.

### Changed

- Typing indicator better matches message length (~80 WPM).

## [0.1.1] - 2021-11-19

### Fixed

- Proper Dockerfile start configuration.

## [0.1.0] - 2021-11-19

Initial release.
