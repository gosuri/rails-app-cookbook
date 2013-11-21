#
# Cookbook Name:: rails-app
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#
#

include_recipe "apt"
include_recipe "nginx"
include_recipe "aws-rds"

aws         = data_bag_item "keys", "aws"
shared_path = "#{node[:app][:deploy_to]}/shared"

node[:app][:packages].each do |pkg|
  package(pkg) do
    action :install
  end
end

directory shared_path do
  recursive true
  action :create
end

aws_rds node[:db][:id] do
  aws_access_key        aws['access_key']
  aws_secret_access_key aws['secret_access_key']
  engine                'postgres'
  db_instance_class     'db.t1.micro'
  allocated_storage     node[:db][:storage]
  master_username       node[:db][:username]
  master_user_password  node[:db][:password]
end

template "#{shared_path}/database.yml" do
  variables lazy {
    {
      env:      node[:app][:env],
      host:     node[:aws_rds][node[:db][:id]][:endpoint_address],
      adapter:  'postgresql',
      encoding: 'unicode',
      database: node[:db][:name],
      username: node[:db][:username],
      password: node[:db][:password]
    }
  }
end

deploy_revision node[:app][:deploy_to] do
  repo node[:app][:repository]
  migrate false
  action :deploy
  environment "RAILS_ENV" => node[:app][:env]
end
