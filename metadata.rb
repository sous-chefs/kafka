name             'kafka'
maintainer       'Burt'
maintainer_email 'mathias@burtcorp.com'
license          'All rights reserved'
description      'Installs/Configures Kafka'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

depends 'java', '>= 1.5'

%w[centos].each do |os|
  supports os
end
