#
# Cookbook Name:: kafka
# Recipe:: topic
#
kafka_topic "test9" do
  action :create
end

kafka_topic "test10" do
  action :update
  partitions 2
end

kafka_topic "test11" do
  action :create
  partitions 2
  replication 2
end
