# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2020-04-05
### Changed
- New branch "mini". Duplicacy_web is no longer baked into the image; it is downloaded as needed based on the specified environment variable, resembling the behaviour of duplicacy command line engine. That way versions can be switched without re-downloading the image appropriate for the architecture -- merely stopping, changing the variable, and starting the image.

## [0.0.8] - 2020-03-02
### Changed
- Bumped duplicacy_web version to 1.2.1

## [0.0.7] - 2020-02-11
### Changed
- Bumped duplicacy_web version to 1.2.0

## [0.0.6] - 2019-10-28
### Changed
- Bumped duplicacy_web version to 1.1.0

## [0.0.5] - 2019-09-15
### Changed
- Honor TZ environment variable

## [0.0.4] - 2019-01-29
### Changed
- Further simplified machine-id handling. The image now has backed link to externally stored machine-id

## [0.0.3] - 2019-01-29
### Changed
- Optimized machine-id persistence handling.
- Removed option to disable machine-id persistence, it is now always saved to /config
- duplicacy_web wget download log redirected to stdout now.

## [0.0.2] - 2019-01-29
### Fixed
- Generate new machine-id for a new container instance. [credit](https://forum.duplicacy.com/t/run-web-ui-in-a-docker-container/1505/21) 

## [0.0.1] - 2019-01-29
### Added
- Initial public release.
