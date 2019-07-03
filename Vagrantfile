my_box    = ENV['MY_BOX'] || 'generic/ubuntu1604'

Vagrant.configure("2") do |config|
  config.vm.box = "#{my_box}"

  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider 'virtualbox' do |v|
    v.memory = 4096
    v.cpus = 2
  end
end

