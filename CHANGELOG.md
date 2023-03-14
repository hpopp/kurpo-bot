# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
