Vagrant.configure('2') do |c|
  if Vagrant.has_plugin?('vagrant-cachier')
    c.cache.auto_detect = true
    c.cache.scope = :box
  end
  c.vm.provider 'virtualbox' do |v|
    v.customize [
      'storagectl', :id,
      '--name', 'SATA Controller',
      '--hostiocache', 'on'
    ]
  end
end
