# kafka_install

Installs Apache Kafka from an official binary tarball.

## Actions

| Action | Description |
|--------|-------------|
| `:install` | Downloads, validates, extracts, owns, and links Kafka. |
| `:delete` | Removes the install symlink, version install directory, build directory, and cached archive. |

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `instance_name` | String | name property | Resource instance name. |
| `version` | String | `'4.2.0'` | Kafka version to install. |
| `scala_version` | String | `'2.13'` | Scala artifact version. |
| `base_url` | String | `'https://downloads.apache.org/kafka'` | Base URL for Apache Kafka downloads. |
| `checksum` | String, nil | `nil` | SHA-256 checksum passed to `remote_file`. |
| `md5_checksum` | String, nil | `nil` | Optional MD5 validation checksum. |
| `sha512_checksum` | String, nil | Kafka 4.2.0 SHA512 | Optional SHA512 validation checksum. |
| `install_dir` | String | `'/opt/kafka'` | Stable install symlink path. |
| `version_install_dir` | String | `'/opt/kafka-<version>'` | Versioned install directory. |
| `build_dir` | String | Chef cache path | Temporary extraction directory. |
| `user` | String | `'kafka'` | Owner for installed files. |
| `group` | String | `'kafka'` | Group for installed files. |

## Examples

```ruby
kafka_install 'default'
```
