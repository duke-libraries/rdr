# rdr

A generated Hyrax-based Research Data Repository application

Note that this application is intended to run within the [rdr-vagrant](https://github.com/duke-libraries/rdr-vagrant) virtual machine


## Setup Vagrant Environment

1. clone the [rdr-vagrant](https://github.com/duke-libraries/rdr-vagrant) repository `git clone https://github.com/duke-libraries/rdr-vagrant.git`
2. move to the rdr-vagrant folder `cd rdr-vagrant`
3. startup vagrant `vagrant up`

   ***

   *This will run through provisioning the new Virtual Machine. The first time it runs, it will take a while to complete. In the future when you want to startup the dev environment, you'll run the same command but it will startup much more quickly*

   *After the setup has completed, you will will be able to shell into the new VM by running `vagrant ssh` and then move to the application folder by running `cd /vagrant/rdr-vagrant`*

   *Vagrant creates this as a shared folder that you can access both inside the VM and on your workstation. We've found it's best to do your git operations exclusively via the workstation folder.*


## Install the rdr application

4. clone this repo
`git clone https://github.com/duke-libraries/rdr.git`

5. shell into vagrant box 
`vagrant ssh`

6. change to the new folder
`cd /vagrant/rdr`

7. grab the bunder gem `gem install bundler`

8. run `bundle install`

9. start the server
`bin/rails hydra:server`
    
    You should be able to visit [localhost:3000](http://localhost:3000) and see the application running

10. create default work type
`rails generate hyrax:work Work`

11. Have fun!


## Installation Notes

* includes a pre-generated gemset named rdr which lives in the root of the project


## Solr and Fedora

* [SOLR](https://github.com/apache/lucene-solr) should be running on [:8983](http://localhost:8983)
* [Fedora](https://github.com/fcrepo4/fcrepo4) should be running on [:8984](http://localhost:8984)
* Solr and Fedora now run individually (so we don't need to run rake tasks) see [Run the wrappers](https://github.com/samvera/hyrax/wiki/Hyrax-Development-Guide#run-the-wrappers).


## Environment (via rdr-vagrant)

* Ubuntu 16.04 64-bit base machine
* [Solr 6.6.0](http://lucene.apache.org/solr/): [http://localhost:8983/solr/](http://localhost:8983/solr/)
* [Fedora 4.7.1](http://fedorarepository.org/): [http://localhost:8984/](http://localhost:8984/)
* [Ruby 2.4.2](https://www.ruby-lang.org) (managed by RVM)
* [Rails 5.1.4](http://rubyonrails.org/)


## References

This is based on the [Samvera Hyrax](https://github.com/samvera/hyrax#creating-a-hyrax-based-app) installation instructions
