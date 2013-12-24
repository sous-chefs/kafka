# encoding: utf-8

Vagrant.configure('2') do |config|
  config.vm.box = 'opscode-centos-6.4'
  config.vm.box_url = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box'

  config.omnibus.chef_version = :latest
  config.berkshelf.enbaled = true

  config.vm.define 'zookeeper' do |zookeeper|
    zookeeper.vm.network :private_network, ip: '192.168.50.5'
    zookeeper.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', '512']
    end

    zookeeper.vm.provision :chef_solo do |chef|
      chef.add_recipe 'java'
      chef.add_recipe 'kafka::zookeeper'
    end
  end

  config.vm.define 'broker' do |broker|
    broker.vm.network :private_network, ip: '192.168.50.10'
    broker.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', '512']
    end

    broker.vm.provision :chef_solo do |chef|
      chef.add_recipe 'java'
      chef.add_recipe 'kafka'
      chef.json = {
        'kafka' => {
          'zookeeper' => {
            'connect' => ['192.168.50.5:2181']
          }
        }
      }
    end
  end
end
