#
# Cookbook Name:: kafka
# Resource:: install
#

actions :run
default_action :run

attribute :to, kind_of: String, name_attribute: true
attribute :from, kind_of: String, required: true
