Changelog
=========

<!--
## [Unreleased]
### Added - for new features.
### Changed - for changes in existing functionality.
### Deprecated - for soon-to-be removed features.
### Removed - for now removed features.
### Fixed - for any bug fixes.
### Security - in case of vulnerabilities.
-->

## [Unreleased]
### Changed
* **README.md** will now be included in release source code archives.

### Fixed
* `Test-Module.ps1` no longer replaces instances of the module name throughout the entire manifest. This was causing issues in certain circumstances where **verdeadmin** would be changed to **verdeadmin-test** within an email address or function name.


## [0.0.7]
### Added
* Dynamic module framework
* CHANGELOG.md
* README.md
* **build_config.ps1** - used to configure module name and publishing repository
* **Test-Module.ps1** - used for testing module changes locally
* **Publish-Module.ps1** - used for publishing module changes to configured repository


[Unreleased]: https://scm.starbucks.com/cbarton/ModuleTemplate/compare/0.0.7...HEAD
[0.0.7]: https://scm.starbucks.com/cbarton/ModuleTemplate/compare/2d1f1ac...0.0.7
