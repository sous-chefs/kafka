# encoding: utf-8

name             'kafka'
maintainer       'Mathias Söderberg'
maintainer_email 'mths@sdrbrg.se'
license          'Apache-2.0'
description      'Installs and configures a Kafka broker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.2.1'

recipe 'kafka::default', 'Downloads and installs Kafka from binary releases'

supports 'centos'
supports 'fedora'
supports 'amazon'
supports 'debian'
supports 'ubuntu'

chef_version '>= 12.1' if respond_to?(:chef_version)

source_url 'https://github.com/mthssdrbrg/kafka-cookbook'
issues_url 'https://github.com/mthssdrbrg/kafka-cookbook/issues'
