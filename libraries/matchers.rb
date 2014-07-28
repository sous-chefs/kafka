#
# Cookbook Name:: kafka
# Libraries:: matchers
#

if defined?(ChefSpec)
  def create_kafka_download(local_path)
    ChefSpec::Matchers::ResourceMatcher.new(:kafka_download, :create, local_path)
  end

  def run_kafka_install(path)
    ChefSpec::Matchers::ResourceMatcher.new(:kafka_install, :run, path)
  end

  def create_kafka_topic(topic_name)
    ChefSpec::Matchers::ResourceMatcher.new(:kafka_topic, :create, topic_name)
  end

  def update_kafka_topic(topic_name)
    ChefSpec::Matchers::ResourceMatcher.new(:kafka_topic, :update, topic_name)
  end
end
