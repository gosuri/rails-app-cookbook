name             'rails-app'
maintainer       'Greg Osuri'
maintainer_email 'gosuri@gmail.com'
license          'All rights reserved'
description      'Installs/Configures rails-app'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{
  apt
  nginx
  aws-rds
}.each do |str|
  depends str
end
