# Limitations

## Package Availability

### APT (Debian/Ubuntu)

- Apache Kafka does not publish an official APT repository.
- Debian 12 and Ubuntu 24.04 deployments use the upstream Kafka binary tarball plus a separately managed Java runtime.

### DNF/YUM (RHEL family)

- Apache Kafka does not publish an official DNF/YUM repository.
- Rocky Linux 9 deployments use the upstream Kafka binary tarball plus a separately managed Java runtime.

### Zypper (SUSE)

- Apache Kafka does not publish an official Zypper repository.

## Architecture Limitations

- Apache Kafka upstream publishes generic binary tarballs instead of distro-specific packages.
- The upstream broker build currently supports Scala 2.13 only.
- Runtime compatibility depends on a supported Java runtime rather than distro packaging metadata.

## Source/Compiled Installation

### Build Dependencies

| Platform Family | Packages |
|-----------------|----------|
| Debian          | OpenJDK 17+, git, tar, gzip |
| RHEL            | OpenJDK 17+, git, tar, gzip |

- Apache Kafka source builds use the upstream Gradle wrapper (`./gradlew`); there is no official source build path in this cookbook.

## Known Issues

- The legacy cookbook defaulted to Kafka 1.1.1 and Scala 2.11, both of which are obsolete for a modern migration.
- Apache Kafka no longer ships official init-system integration for SysV or Upstart, so this migration is systemd-only.
- Kafka can run in ZooKeeper mode or KRaft mode, but a single-node default test suite is only practical in KRaft mode because this cookbook does not manage ZooKeeper.
