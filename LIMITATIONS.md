# Limitations

## Package Availability

This cookbook installs Apache Kafka from the official Apache binary tarballs. It does not configure
APT, DNF/YUM, or Zypper package repositories.

### Binary Downloads

* Apache Kafka 4.2.0 is available from `https://downloads.apache.org/kafka/4.2.0/`.
* The default artifact is `kafka_2.13-4.2.0.tgz`.
* Apache provides `asc`, `md5`, `sha1`, and `sha512` checksum files for the artifact.

## Platform Support

The cookbook is tested with Dokken on these non-EOL Linux platforms:

* AlmaLinux 9 and 10
* Amazon Linux 2023
* CentOS Stream 9 and 10
* Debian 12 and 13
* Fedora latest
* Oracle Linux 9 and 10
* Rocky Linux 9 and 10
* Ubuntu 22.04 and 24.04

openSUSE Leap is not included because Leap 15.6 reached end of life on April 30, 2026, and Leap 16
Dokken support has not been confirmed.

## Architecture Limitations

Apache Kafka binary tarballs are architecture-independent JVM artifacts. The supported architecture
is therefore constrained by the platform's Java 17 or newer runtime availability and the
Kitchen/Dokken image used for testing.

## Java Requirements

Kafka 4.x removed Java 8 support for servers. The cookbook assumes Java 17 or newer is installed by
the caller. The integration test cookbook installs Java 17 where available, and Java 21 on newer
platform images where Java 17 packages are unavailable.

## Source/Compiled Installation

Source builds are not managed by this cookbook. The `kafka_install` resource only supports binary
tarball installation.

## Known Issues

Kafka 4.x uses KRaft by default for new clusters. When `format_storage true` is used, callers must
provide a valid `cluster_id` and KRaft-compatible broker configuration.
