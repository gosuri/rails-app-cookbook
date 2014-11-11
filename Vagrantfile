# -*- mode: ruby -*-
# vi: set ft=ruby :

current_dir = File.expand_path File.dirname(__FILE__)

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
  if Vagrant.has_plugin?('vagrant-env')
    config.env.enable
    if File.exists?("#{current_dir}/.env")
      print "loading vars from from .env\n"
    else
      print "unable to set local environment vars as .env file doesn't exits. \n see https://github.com/gosuri/vagrant-env/blob/master/README.md \n"
    end
  else
    $stderr.puts <<ERR 
      FATAL: vagrant-env plugin not detected. Please install the plugin with
             'vagrant plugin install vagrant-env' from any other directory
              before continuing
ERR
    exit
  end
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
