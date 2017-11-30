# rdr

A generated Hyrax-based Research Data Repository application

*Note that this application is intended to run within the [rdr-vagrant](https://github.com/duke-libraries/rdr-vagrant) virtual machine*


## Prerequisites (vagrant / virtualbox)

* [Vagrant](https://www.vagrantup.com/) version 1.8.5+

   *You can quickly check to see if you have a suitable version of vagrant installed by running `vagrant -v`*

   *If you don't have vagrant installed, you can [download it](https://www.vagrantup.com/downloads.html) -- it's available for both Mac and Windows, as well as Debian and Centos.*

* [VirtualBox](https://www.virtualbox.org/)

   *Vagrant runs inside of a Virtual Machine (VM) hosted by VirtualBox, which is made by Oracle and is free to [download](https://www.virtualbox.org/wiki/Downloads). They have version for Mac and Windows, as well as Linux and Solaris.*

   *You can quickly check to see if you have VirtualBox installed by running `vboxmanage --version`*


## Setup the Environment


### Vagrant

1. clone the [rdr-vagrant](https://github.com/duke-libraries/rdr-vagrant) repository `git clone https://github.com/duke-libraries/rdr-vagrant.git`
2. move to the rdr-vagrant folder `cd rdr-vagrant`
3. startup vagrant `vagrant up`

   *This will run through provisioning the new Virtual Machine. The first time it runs, it will take a while to complete. In the future when you want to startup the dev environment, you'll run the same command but it will startup much more quickly*

   *Vagrant creates a shared folder that you can access both inside the VM and on your workstation. We've found it's best to do your git operations exclusively via the workstation folder.*


### rdr application

4. clone this repo
`git clone https://github.com/duke-libraries/rdr.git` 

   OR using ssh `git clone git@github.com:duke-libraries/rdr.git` 
   *note that you'll need to have [setup keys in github](https://help.github.com/articles/connecting-to-github-with-ssh/) to use this approach*

5. shell into vagrant box
`vagrant ssh`

6. change to the new folder
`cd /vagrant/rdr`

7. Copy the role map config file `cp config/role_map.yml.sample config/role_map.yml`

8. grab the bunder gem `gem install bundler`

9. run `bundle install`

10. run database migrations `rake db:migrate`

11. load default workflow `rake rake hyrax:workflow:load`

12. start the server(s)
`bin/rails hydra:server`

    *This starts Solr, Fedora, and Rails*

13. create default admin set &mdash; open a new terminal tab (Ctrl-T or ⌘-T), shell into vagrant `vagrant ssh`, and move to the correct folder `cd /vagrant/rdr`

    then run `bin/rails hyrax:default_admin_set:create`

    you can close the tab when it's done


14. The application should now be running at [localhost:3000](http://localhost:3000). You can try to do some things like creating a new user account and depositing an object


### Shut down the application

* to shut down the app, stop the rails server by pressing Ctrl-C (⌘-C), logout of vagrant `logout`, and then shutdown the VM `vagrant halt`


### Start up the application

* to startup again, run `vagrant up`, `vagrant ssh`, `cd /vagrant/rdr`, and `bin/rails hydra:server`



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

Instructions are based on the [Samvera Hyrax](https://github.com/samvera/hyrax#creating-a-hyrax-based-app) installation instructions
