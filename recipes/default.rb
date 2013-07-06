#
# Cookbook Name:: kafka
# Recipe:: default
#
# Copyright 2013, Burt
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'java'

java_home        = node[:java][:home]
user             = node[:kafka][:user]
group            = node[:kafka][:group]

broker_id        = node[:kafka][:broker_id]
broker_host_name = node[:kafka][:broker_host_name]

if broker_id.nil? || broker_id.empty?
  node[:kafka][:broker_id] = node[:ipaddress].gsub(".", "")
end

if broker_host_name.nil? || broker_id.empty?
  node[:kafka][:broker_host_name] = node[:fqdn]
end

log "broker_id = #{node[:kafka][:broker_id]}"
log "broker_host_name = #{node[:kafka][:broker_host_name]}"

group(group) {}

user(user) do
  comment 'User for Kafka'
  gid 'kafka'
  home '/home/kafka'
  shell '/bin/false'
  supports(:manage_home => false)
end

install_dir = node[:kafka][:install_dir]

directory "#{install_dir}" do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
  not_if { File.directory?("#{install_dir}") }
end

directory "#{install_dir}/bin" do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
  not_if { File.directory?("#{install_dir}/bin") }
end

directory "#{install_dir}/config" do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
  not_if { File.directory?("#{install_dir}/config") }
end

directory node[:kafka][:log_dir] do
  owner   user
  group   group
  mode    00755
  recursive true
  action :create
  not_if { File.directory?(node[:kafka][:log_dir]) }
end

directory node[:kafka][:data_dir] do
  owner   user
  group   group
  mode    00755
  recursive true
  action :create
  not_if { File.directory?(node[:kafka][:data_dir]) }
end

include_recipe 'kafka::config'
