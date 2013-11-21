# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "rails-app-berkshelf"
  config.vm.box = "raring_13_04-x86_64-minimal"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-i386-vagrant-disk1.box"
  config.vm.network :private_network, ip: "33.33.33.10"
  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = "data_bags"
    chef.run_list = %w(recipe[rails-app::default])
  end
  
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest
end
