# frozen_string_literal: true

name             'kafka'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Provides a kafka_broker resource for installing and managing Apache Kafka brokers'
version          '4.0.0'
chef_version     '>= 15.3'
source_url       'https://github.com/sous-chefs/kafka'
issues_url       'https://github.com/sous-chefs/kafka/issues'

supports 'debian', '>= 12.0'
supports 'rocky', '>= 9.0'
supports 'ubuntu', '>= 24.04'
