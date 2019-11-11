# rdr

A generated Hyrax-based Research Data Repository application

*Note that this application is designed to run within the [rdr-vagrant](https://github.com/duke-libraries/rdr-vagrant) virtual machine*


## Prerequisites (vagrant / virtualbox)

* [Vagrant](https://www.vagrantup.com/) version 1.8.5+

   *You can quickly check to see if you have a suitable version of vagrant installed by running `vagrant -v`*

   *If you don't have vagrant installed, you can [download it](https://www.vagrantup.com/downloads.html) -- it's available for both Mac and Windows, as well as Debian and Centos.*

* [VirtualBox](https://www.virtualbox.org/)

   *Vagrant runs inside of a Virtual Machine (VM) hosted by VirtualBox, which is made by Oracle and is free to [download](https://www.virtualbox.org/wiki/Downloads). They have version for Mac and Windows, as well as Linux and Solaris.*

   *You can quickly check to see if you have VirtualBox installed by running `vboxmanage --version`*


## Setup the Environment


### Vagrant

1. clone the [rdr-vagrant](https://github.com/duke-libraries/rdr-vagrant) repository `git clone --recursive https://github.com/duke-libraries/rdr-vagrant.git`
2. move to the *rdr-vagrant* folder `cd rdr-vagrant`
3. startup vagrant `vagrant up`

   *This will run through provisioning the new Virtual Machine. The first time it runs, it will take a while to complete. In the future when you want to startup the dev environment, you'll run the same command but it will startup much more quickly*

   *Vagrant creates a shared folder that you can access both inside the VM and on your workstation. We've found it's best to do your git operations exclusively via the workstation folder.*


### rdr application

4. This repo ([rdr](https://github.com/duke-libraries/rdr)) is included as a submodule in rdr-vagrant, so the folder and files are there already.

   However, we need to specify that we will be using the *develop* branch.

   move to the *rdr* folder `cd rdr`

   specify the branch `git checkout develop`

   move back to the *rdr-vagrant* folder `cd ..`


5. shell into vagrant box
`vagrant ssh`

6. change to the new folder
`cd /vagrant/rdr`

~~7. Copy the role map config file `cp config/role_map.yml.sample config/role_map.yml`~~ *no longer needed -- [see below](#3212018----changes-to-role-management)*

8. grab the bunder gem `gem install bundler`

9. run `bundle install --without production`

10. setup Postgres ([see confluence documentation](https://duldev.atlassian.net/wiki/spaces/DDR/pages/427491331/One-Time+Setup+to+Use+Postgres+instead+of+Sqlite)]:

    a. Create a 'hydra' postgres user (role): `psql -c "CREATE USER hydra WITH PASSWORD 'hydra' CREATEDB;" postgres`
  
    b. Create a development postgres database: `psql -c "CREATE DATABASE development WITH OWNER hydra;" postgres`
  
    c. Create a test postgres database: `psql -c "CREATE DATABASE test WITH OWNER hydra;" postgres`
  
    d. Set up the development and test databases: `rake db:schema:load`

11. run database migrations `rake db:migrate`

12. load default workflow `rake hyrax:workflow:load`

13. start the server(s)
`bin/rails hydra:server`

    *This starts Solr, Fedora, and Rails*

14. create default admin set &mdash; open a new terminal tab (Ctrl-T or ⌘-T), shell into vagrant `vagrant ssh`, and move to the correct folder `cd /vagrant/rdr`

    then run `bin/rails hyrax:default_admin_set:create`

    you can close the tab when it's done


15. The application should now be running at [localhost:3000](http://localhost:3000). You can try to do some things like [creating a new user account](http://localhost:3000/users/sign_up?locale=en) and [depositing an object](http://localhost:3000/concern/works/new?locale=en)

    *Note that if you would like to give your user account admin rights, you'll need follow the [instructions below](#3212018----changes-to-role-management)


### Shut down the application

* to shut down the app, stop the rails server by pressing Ctrl-C, logout of vagrant `logout`, and then shutdown the VM `vagrant halt`


### Starting up the application

It is best to run Solr, Fedora, and Rails in three separate tabs:
* startup the vagrant instance: ```vagrant up```
* ssh into vagrant ```vagrant ssh```
* move to the correct folder ```cd /vagrant/rdr```
* start Fedora ```fcrepo_wrapper```
* open a new terminal tab, ssh in, move to correct folder, and startup Solr ```solr_wrapper```
* open one more terminal tab, ssh in, move to correct folder, and startup rails ```rails server -b 0.0.0.0```


## Solr and Fedora

* [SOLR](https://github.com/apache/lucene-solr) should be running on [:8983](http://localhost:8983)
* [Fedora](https://github.com/fcrepo4/fcrepo4) should be running on [:8984](http://localhost:8984)
* Solr and Fedora now run individually (so we don't need to run rake tasks) see [Run the wrappers](https://github.com/samvera/hyrax/wiki/Hyrax-Development-Guide#run-the-wrappers).


## Environment (via rdr-vagrant)

* Ubuntu 16.04 64-bit base machine
* [Solr 7.1.0](http://lucene.apache.org/solr/): [http://localhost:8983/solr/](http://localhost:8983/solr/)
* [Fedora 4.7.4](http://fedorarepository.org/): [http://localhost:8984/](http://localhost:8984/)
* [Ruby 2.4.2](https://www.ruby-lang.org) (managed by RVM)
* [Rails 5.1.4](http://rubyonrails.org/)


## References

Instructions are based on the [Samvera Hyrax](https://github.com/samvera/hyrax#creating-a-hyrax-based-app) installation instructions


## Addenda

### 3/21/2018 -- Changes to role management

Previously we were using the default role management in Hyrax which used <code>config/role_map.yml</code> to assign users to roles. We're no longer using the yml file and are instead using the [hydra-role-management](https://github.com/samvera/hydra-role-management) gem so there are a few extra steps you'll need to take to get things to work.

1. run database migrations using: <code>rake db:migrate</code>
        
2. add a user to the admin group via the rails console
    
    use `rails c` to start the console
    
    then enter:
    
    `admin = Role.create(name: "admin")` 
    
    `admin.users << User.find_by_user_key( "your_admin_user_name" )`
    
    `admin.save`

    and then exit the console: `exit`
    
3. start up the server `rails server -b 0.0.0.0`, sign in using the 'admin' user you assigned above, and visit [localhost:3000/roles](http://localhost:3000/roles) which should allow you to view existing roles, create new ones, and assign users to them. 

    **Note: if you had established other user roles in the role_map.yml file, you'll need to manually assign those users using this process**

4. If you have any problems, you can test whether a user has been assigned to either the admin or curator groups (as these have defined methods on the User class) using the rails console as follows:

    `u = User.find_by_user_key( "your_user_id_name" )`

    `u.admin?`
    
    `u.curator?`
    
    If either returns true, you know your user is in that group.


