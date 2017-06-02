KafkaError = Class.new(StandardError)

def whyrun_supported?
  true
end

action :create do
  converge_by("Creating topic #{@new_resource.name}") do
    initVars
    create_topic(@new_resource.name)
    resname = @new_resource.name
    ruby_block "verify-topic-#{resname}" do
      block do
        unless topic_exists?(resname) 
          Chef::Log.info "topic was not created #{resname}."
        else
          Chef::Log.info "topic was created #{resname}"
        end
      end
      action :run
    end
  end
end

action :update do
  converge_by("Updating configuration for topic #{@new_resource.name}") do
    initVars
    alter_topic(@new_resource.name)
  end
end

def topic_exists?(topic_name)
  listCmd = "#{@topic_cmd} --list --zookeeper #{@zk_hosts} | grep -i #{topic_name}"
  cmd = Mixlib::ShellOut.new(listCmd)
  cmd.run_command
  begin
    cmd.error!
    return true
  rescue
    Chef::Log.debug "Exception while finding topic #{topic_name} : #{cmd.stderr}"
    return false
  end
end

def create_topic(topic_name)
  create_cmd = "#{@topic_cmd} --create --zookeeper #{@zk_hosts} --replication-factor #{@new_resource.replication} --partitions #{@new_resource.partitions} --topic #{@new_resource.name}"
  Chef::Log.info "Creating topic using command :: #{create_cmd}"
  bash "create-kafka-topic-#{topic_name}"  do
    code create_cmd
    user "root"
    action :run
    not_if { topic_exists?(topic_name) }
  end
end

def alter_topic(topic_name)
  alter_cmd = "#{@topic_cmd} --alter --zookeeper #{@zk_hosts} --topic #{@new_resource.name} --partitions #{@new_resource.partitions}"
  Chef::Log.info "Altering topic using command :: #{alter_cmd}"
  bash "alter-kafka-topic-#{topic_name}" do
    code alter_cmd
    user "root"
    action :run
    only_if { topic_exists?(topic_name) }
  end
end

private
def initVars
  # Instance variable declaration
  @zk_hosts = node[:kafka][:zookeeper][:connect].map{|x| x + ":#{node[:zookeeper][:port]}#{node[:zookeeper][:path]}"}.join(",")
  if @zk_hosts.empty?
    raise KafkaError.new("Zookeeper hosts not found..")
  end
  @kafka_bin = "#{node[:kafka][:install_dir]}/bin"
  @topic_cmd = "#{@kafka_bin}/kafka-topics.sh"
end
