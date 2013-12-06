# -*- mode: ruby -*-
# vi: set ft=ruby :
BOX_NAME        = ENV['BOX_NAME']         || "dummy"
BOX_URL         = ENV['BOX_URL']          || "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
SECURITY_GROUPS = ENV['SECURITY_GROUPS']  || "web" # space separated
AWS_REGION      = ENV['AWS_REGION']       || "us-east-1"
AWS_AMI         = ENV['AWS_AMI']          || "ami-7747d01e"

$chef = <<SHELL
sudo apt-get update
sudo apt-get install build-essential ruby1.9.3 -y
sudo gem install chef --no-ri --no-rdoc
SHELL

Vagrant.configure("2") do |config|
  config.vm.box     = BOX_NAME
  config.vm.box_url = BOX_URL
  config.vm.provision "shell", inline: $chef

  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = "data_bags"
    chef.run_list = %w(recipe[rails-app::default])
    chef.json = {
      "aws_access_key_id"     => ENV['AWS_ACCESS_KEY_ID'],
      "aws_secret_access_key" => ENV['AWS_SECRET_ACCESS_KEY']
    }
  end

  config.vm.provider :aws do |aws, override|
    aws.ami                       = AWS_AMI
    aws.region                    = AWS_REGION
    aws.keypair_name              = ENV['AWS_KEYPAIR_NAME']
    aws.access_key_id             = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key         = ENV['AWS_SECRET_ACCESS_KEY']
    aws.security_groups           = SECURITY_GROUPS.split
    override.ssh.username         = "ubuntu"
    override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
  end
end
