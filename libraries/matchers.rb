# encoding: utf-8

if defined?(ChefSpec)
  def create_kafka_download(local_path)
    ChefSpec::Matchers::ResourceMatcher.new(:kafka_download, :create, local_path)
  end
end
