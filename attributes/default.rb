default[:app][:id]          = 'rails-app'
default[:app][:env]         = "production"
default[:app][:deploy_to]   = "/mnt/apps/#{node[:app][:id]}"
default[:app][:packages]    = %w(git ruby1.9.3)

default[:app][:repository]  = 'https://github.com/gosuri/rails-app.git'
default[:app][:revision]    = 'master'

default[:db][:id]       = node[:app][:id]
default[:db][:name]     = 'rails_app'
default[:db][:username] = 'railsappuser'
default[:db][:password] = 'insecure'
default[:db][:storage]  = 5
