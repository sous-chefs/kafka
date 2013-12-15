Vagrant.configure("2") do |config|
  config.vm.box = "opscode-centos-6.4"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box"

  config.omnibus.chef_version = :latest
  config.berkshelf.enbaled = true
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe 'java'
    chef.add_recipe 'kafka'
    chef.log_level = :debug
    chef.json = {}
  end
end
