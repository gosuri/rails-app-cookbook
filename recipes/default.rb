#
# Cookbook Name:: rails-app
# Recipe:: default
#
# Copyright (c) 2013 Greg Osuri <gosuri@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

include_recipe "apt"
include_recipe "nginx"
include_recipe "aws-rds"
include_recipe "supervisor"

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
  aws_access_key        node[:aws_access_key_id]
  aws_secret_access_key node[:aws_secret_access_key]
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
      env:      node[:app][:rails_env],
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
  environment "RAILS_ENV" => node[:app][:rails_env]
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
