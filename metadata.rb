name             'kafka'
maintainer       'Mathias Söderberg'
maintainer_email 'mths@sdrbrg.se'
license          'Apache 2.0'
description      'Installs and configures a Kafka broker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

recipe 'kafka', 'Setups up install environment'
recipe 'kafka::source', 'Downloads, compiles and installs Kafka from source releases'
recipe 'kafka::binary', 'Downloads, extracts and installs Kafka from binary releases'
recipe 'kafka::standalone', 'Setups standalone ZooKeeper instance using the ZooKeeper version that is bundled with Kafka'

depends 'java', '~> 1.11.6'

%w[centos].each do |os|
  supports os
end
