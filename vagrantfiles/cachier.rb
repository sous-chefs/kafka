Vagrant.configure('2') do |c|
  if Vagrant.has_plugin?('vagrant-cachier')
    c.cache.auto_detect = true
    c.cache.scope = :box
  end
end
