# encoding: utf-8

name             'kafka'
maintainer       'Mathias Söderberg'
maintainer_email 'mths@sdrbrg.se'
license          'Apache 2.0'
description      'Installs and configures a Kafka broker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.2'

recipe 'kafka::default', 'Downloads and installs Kafka from binary releases'

suggests 'java', '~> 1.22'

supports 'centos'
supports 'fedora'
supports 'amazon'
supports 'debian'
supports 'ubuntu'
