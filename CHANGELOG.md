# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2026-01-30

### Added

- Add `bin/build` script and `buildpack.toml` files for CNB compatibility. ([#10](https://github.com/heroku/heroku-buildpack-heroku-applink-service-mesh/pull/10))

## [1.0.1] - 2025-07-07

### Added

- Add shellcheck to CI. ([#12](https://github.com/heroku/heroku-buildpack-heroku-applink-service-mesh/pull/12))

### Fixed

- Fix binary link to use /app as the source instead of the temporary build dir. ([#15](https://github.com/heroku/heroku-buildpack-heroku-applink-service-mesh/pull/15))

## [1.0.0] - 2025-06-24

### Added

- Initial release.

[unreleased]: https://github.com/heroku/heroku-buildpack-heroku-applink-service-mesh/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/heroku/heroku-buildpack-heroku-applink-service-mesh/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/heroku/heroku-buildpack-heroku-applink-service-mesh/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/heroku/heroku-buildpack-heroku-applink-service-mesh/releases/tag/v1.0.0
