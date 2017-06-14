# encoding: utf-8

name             'kafka'
maintainer       'Mathias'
maintainer_email 'mths@sdrbrg.se'
license          'Apache 2.0'
description      'Installs and configures a Kafka broker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.2.1'

recipe 'kafka::default', 'Downloads and installs Kafka from binary releases'

suggests 'java', '~> 1.22' # ~FC052

supports 'centos'
supports 'fedora'
supports 'amazon'
supports 'debian'
supports 'ubuntu'

chef_version '>= 12.1' if respond_to?(:chef_version)

source_url 'https://github.com/mthssdrbrg/kafka-cookbook' if respond_to?(:source_url)
issues_url 'https://github.com/mthssdrbrg/kafka-cookbook/issues' if respond_to?(:issues_url)
