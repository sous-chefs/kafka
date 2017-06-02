actions :create, :update
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :partitions, kind_of: Integer, default: 1
attribute :replication, kind_of: Integer, default: 1
