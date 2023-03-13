# Changelog

## [20] - 2023-03-13
### Changed
- Bumped duplicacy_web version to 1.7.2

## [19] - 2023-02-22
### Changed
- Bumped duplicacy_web version to 1.7.0

## [18] - 2022-11-17
### Changed
- Bumped duplicacy_web version to 1.6.3

## [17] - 2022-05-11
### Changed
- Bumped duplicacy_web version to 1.6.2

## [16] - 2022-05-09
### Changed
- Bumped duplicacy_web version to 1.6.1

## [15] - 2022-04-29
### Changed
- Bumped duplicacy_web version to 1.6.0

## [14] - 2021-01-20
### Changed
- Bumped duplicacy_web version to 1.5.0

## [13] - 2020-11-30
### Changed
- Added support for aarch64

## [12] - 2020-08-25
### Added
- Added ARMv7 image. Unified Dockerfile for both architectures to take advantage of buildx

## [11] - 2020-08-23
### Changed
- Bumped duplicacy_web version to 1.4.1. `DWE_PASSWORD` is no longer required; updated readme accordingly.

## [10] - 2020-08-07
### Changed
- Bumped duplicacy_web version to 1.4.0

## [9] - 2020-04-15
### Changed
- Bumped duplicacy_web version to 1.3.0

## [8] - 2020-03-02
### Changed
- Bumped duplicacy_web version to 1.2.1

## [7] - 2020-02-11
### Changed
- Bumped duplicacy_web version to 1.2.0

## [6] - 2019-10-28
### Changed
- Bumped duplicacy_web version to 1.1.0

## [5] - 2019-09-15
### Changed
- Honor TZ environment variable

## [4] - 2019-01-29
### Changed
- Further simplified machine-id handling. The image now has backed link to externally stored machine-id

## [3] - 2019-01-29
### Changed
- Optimized machine-id persistence handling.
- Removed option to disable machine-id persistence, it is now always saved to /config
- duplicacy_web wget download log redirected to stdout now.

## [2] - 2019-01-29
### Fixed
- Generate new machine-id for a new container instance. [credit](https://forum.duplicacy.com/t/run-web-ui-in-a-docker-container/1505/21) 

## [1] - 2019-01-29
### Added
- Initial public release.
