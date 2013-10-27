Vagrant.configure("2") do |config|
  config.vm.box = "opscode-centos-6.4"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box"

  config.omnibus.chef_version = :latest
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["vendor/cookbooks"]
    # chef.roles_path = "../chef-repo/roles"
    # chef.data_bags_path = "../chef-repo/data_bags"
    # chef.add_role "my_role"
    chef.add_recipe "kafka::binary"
    chef.log_level = :debug
    chef.json = {}
  end
end
