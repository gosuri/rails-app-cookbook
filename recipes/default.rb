#
# Cookbook Name:: rails-app
# Recipe:: default
#
# Copyright (C) 2013 Greg Osuri
# 
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
include_recipe "nginx"
include_recipe "aws-rds"
include_recipe "supervisor"

aws         = data_bag_item "keys", "aws"
shared_path = "#{node[:app][:deploy_to]}/shared"

node[:app][:packages].each do |pkg|
  package(pkg) do
    action :install
  end
end

node[:app][:gems].each do |gem|
  gem_package(gem) do
    action :install
  end
end

directory "#{shared_path}/log" do
  recursive true
  action :create
end

aws_rds node[:db][:id] do
  aws_access_key        aws['access_key']
  aws_secret_access_key aws['secret_access_key']
  engine                'postgres'
  db_instance_class     'db.t1.micro'
  allocated_storage     node[:db][:storage]
  db_name               node[:db][:name]
  master_username       node[:db][:username]
  master_user_password  node[:db][:password]
  publicly_accessible   true
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
  action :force_deploy
  environment "RAILS_ENV" => node[:app][:env]
  symlink_before_migrate "database.yml" => "config/database.yml"

  before_migrate do
    execute "bundle-install" do
      cwd release_path
      command "/usr/bin/ruby -S bundle install --deployment --path '#{shared_path}/bundle' --without development test"
    end
  end

  notifies :restart, "supervisor_service[#{node[:app][:id]}-unicorn]", :delayed
end

template "#{shared_path}/unicorn.rb" do
  source "unicorn.rb.erb"
  variables(
    worker_processes: 1,
    working_directory: "#{node[:app][:deploy_to]}/current",
    port: 8080,
    timeout: 30
  )
end

supervisor_service "#{node[:app][:id]}-unicorn" do
  directory "#{node[:app][:deploy_to]}/current"
  command "/usr/bin/ruby -S bundle exec unicorn -c #{shared_path}/unicorn.rb -E production"
  user "nobody"
  stdout_logfile "#{shared_path}/log/stdout.log"
  stderr_logfile "#{shared_path}/log/stderr.log"
end

template "/etc/nginx/sites-available/rails-app" do
  source "nginx.conf.erb"
  variables :root => "#{node[:app][:deploy_to]}/current/public"
end

nginx_site "default" do
  enable false
end

nginx_site "rails-app" do
  enable true
end
