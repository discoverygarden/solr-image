# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## [0.0.2] - 2021-11-30
### Changed
- `CRAYFISH_GIT_REF` changed to `CRAYFISH_VERSION`
- `CRAYFISH_VERSION` set to `2.0.0`
### Fixed
- added `fedora_resource.base_url` back into Homarus, Houdini and Hypercube `cfg/config.yaml`s as it sometimes it complain about it missing even though it not being used

## [0.0.1] - 2021-11-29
### Added
- initial release
### TODO
- generation of thumbnail for PDF document currently does not work
- some Apache2 logging not going to stdout/stderr
