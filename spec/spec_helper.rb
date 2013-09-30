# encoding: utf-8

require 'chefspec'
require 'berkshelf'

berksfile = Berkshelf::Berksfile.from_file('Berksfile')
berksfile.install(path: 'vendor/cookbooks')
