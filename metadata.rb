# encoding: utf-8

name             'kafka'
maintainer       'Mathias Söderberg'
maintainer_email 'mths@sdrbrg.se'
license          'Apache 2.0'
description      'Installs and configures a Kafka broker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

recipe 'kafka::source', 'Downloads, compiles and installs Kafka from source releases'
recipe 'kafka::binary', 'Downloads, extracts and installs Kafka from binary releases'
recipe 'kafka::zookeeper', 'Setups standalone ZooKeeper instance using the ZooKeeper version that is bundled with Kafka'

recommends 'java', '~> 1.19'

%w(centos fedora debian ubuntu).each do |os|
  supports os
end
