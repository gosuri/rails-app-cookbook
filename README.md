# Introduction

This chef cookbook setups an example [rails app](https://github.com/gosuri/rails-app) using the [AWS RDS](https://github.com/gosuri/aws-rds-cookbook) cookbook

# Requirements

* Chef 11.4+
* Ruby 1.9.3+
* AWS Credentials

## Non-Gem Dependencies

* Git
* [Vagrant 1.3.5+](http://www.vagrantup.com)
* [vagrant-berkshelf 1.3.4](https://github.com/berkshelf/vagrant-berkshelf): install using `vagrant plugin install vagrant-berkshelf`
* [vagrant-omnibus 1.1.2](https://github.com/schisamo/vagrant-omnibus): install using `vagrant plugin install vagrant-omnibus`

## Runtime Rubygem Dependencies

First you'll need bundler which can be installed with a simple `gem install bundler`. Afterwords, do the following:

```
bundle install
```

# Usage

1. Clone the repo

   ```
   git clone https://github.com/gosuri/rails-app-cookbook.git
   cd rails-app-cookbook
   ```

2. Add your machine IP address to default RDS security group

   You will need to add your IP address to the default RDS security group in order for the RDS instance to be acccessable from your vagrant instance. It should be available at https://console.aws.amazon.com/rds/home?region=us-east-1#securitygroup:ids=default

3. Place AWS credentials in the databag

   Place aws.json that contains your *AWS credentials* under ```data_bags/keys```. You can use the sample ```data_bags/keys/aws.json.sample``` to get started

   ```
   cp data_bags/keys/aws.json.sample data_bags/keys/aws.json 
   ```

   Edit ```data_bags/keys/aws.json``` and place your keys there

4. Install gem dependencies

   First you'll need bundler which can be installed with a simple `gem install bundler`. Afterwords, do the following:

   ```
   bundle install
   ```

5. Run Vagrant

   ```
   vagrant up
   ```

6. Point your browser to http://33.33.33.10 and you should see 'It works!'

# Recipes

* ```default.rb```: The default recipe creates an rds instance and setups the rails app with unicorn and nginx

# Contributing

1. Fork the project on github
2. Commit your changes to your fork
3. Send a pull request

# License & Author

Author:: Greg Osuri (<gosuri@gmail.com>)

Copyright (c) 2013 Greg Osuri 

Licensed under the MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
