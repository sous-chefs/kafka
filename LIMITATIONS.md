# Limitations

## Package Availability

### APT (Debian/Ubuntu)

- Apache Kafka does not publish an official APT repository.
- Debian 12/13 and Ubuntu 22.04/24.04 deployments use the upstream Kafka binary tarball plus a separately managed Java runtime.

### DNF/YUM (RHEL family)

- Apache Kafka does not publish an official DNF/YUM repository.
- AlmaLinux 9/10, CentOS Stream 9/10, Oracle Linux 9/10, and Rocky Linux 9/10 deployments use the upstream Kafka binary tarball plus a separately managed Java runtime.
- Fedora current deployments use the upstream Kafka binary tarball plus a separately managed Java runtime.

### Amazon Linux

- Apache Kafka does not publish an official Amazon Linux repository.
- Amazon Linux 2023 deployments use the upstream Kafka binary tarball plus Amazon Corretto 17.

### Zypper (SUSE)

- Apache Kafka does not publish an official Zypper repository.

## Architecture Limitations

- Apache Kafka upstream publishes generic binary tarballs instead of distro-specific packages.
- The upstream broker build currently supports Scala 2.13 only.
- Runtime compatibility depends on a supported Java runtime rather than distro packaging metadata.
- Kafka 3.9 fully supports Java 17 and Java 21. This cookbook defaults to Java 17 because it is an LTS release that is portable across all currently supported platforms with the available Java cookbook installers; callers can override `java_version` when they need Java 21 on platforms where package-backed installs are available.

## Source/Compiled Installation

### Build Dependencies

| Platform Family | Packages                                                  |
|-----------------|-----------------------------------------------------------|
| Amazon          | Amazon Corretto 17, tar, gzip                             |
| Debian          | OpenJDK 17+/21+, tar, gzip                                |
| Fedora          | OpenJDK 17+/21+, tar, gzip                                |
| RHEL            | OpenJDK 17+/21+ or Amazon Corretto 17 on EL 10, tar, gzip |

- Apache Kafka source builds use the upstream Gradle wrapper (`./gradlew`); there is no official source build path in this cookbook.

## Known Issues

- The legacy cookbook defaulted to Kafka 1.1.1 and Scala 2.11, both of which are obsolete for a modern migration.
- Apache Kafka no longer ships official init-system integration for SysV or Upstart, so this migration is systemd-only.
- Kafka can run in ZooKeeper mode or KRaft mode, but a single-node default test suite is only practical in KRaft mode because this cookbook does not manage ZooKeeper.
- Platform support was revalidated against endoflife.date in April 2026. Ubuntu 20.04, Debian 11, Rocky Linux 8, AlmaLinux 8, and CentOS Stream 8 were intentionally excluded because they are no longer current support targets.
