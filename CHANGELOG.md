# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

- Fix missing newlines in env file and log4j.properties
- Fix serverspec tests
- Fix dokken verifier path
- resolved cookstyle error: test/integration/default/serverspec/default_spec.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/helpers/serverspec/Gemfile:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/helpers/serverspec/spec_helper.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/helpers/serverspec/support/await_helper.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/helpers/serverspec/support/files_common.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/helpers/serverspec/support/platform_helpers.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/helpers/serverspec/support/service_common.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/runit/serverspec/required_files_spec.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/runit/serverspec/service_spec.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/systemd/serverspec/required_files_spec.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/systemd/serverspec/service_spec.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/sysv/serverspec/required_files_spec.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/sysv/serverspec/service_spec.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/upstart/serverspec/required_files_spec.rb:1:1 convention: `Style/Encoding`
- resolved cookstyle error: test/integration/upstart/serverspec/service_spec.rb:1:1 convention: `Style/Encoding`

## 3.1.0

### Added

- Dokken tests
- Migrated to Github Actions

### Fixed

- resolved cookstyle error: recipes/_install.rb:26:9 refactor: `ChefCorrectness/ChefApplicationFatal`
- resolved cookstyle error: recipes/_install.rb:30:9 refactor: `ChefCorrectness/ChefApplicationFatal`

## 3.0.0

- Move to Sous-Chefs organision
