name             'rails-app'
maintainer       'Greg Osuri'
maintainer_email 'gosuri@gmail.com'
license          'MIT'
description      'This chef cookbook setups an example rails app using the aws-rds cookbook'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
%w{
  nginx
  aws-rds
  supervisor
}.each do |str|
  depends str
end
