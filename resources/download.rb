#
# Cookbook Name:: kafka
# Resource:: download
#

actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :source, kind_of: String, required: true
attribute :mode, kind_of: [String, Integer], default: '644'
attribute :checksum, kind_of: String
attribute :md5_checksum, kind_of: String
