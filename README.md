# rdr

A generated Hyrax-based Research Data Repository application


## Local Installation Instructions

1. clone this repo
`git clone https://github.com/duke-libraries/rdr.git`

2. change to the new folder
`cd rdr`

3. start the server
`bin/rails hydra:server`
    
    You should be able to visit [localhost:3000](http://localhost:3000) and see the application running

4. create default admin set
`bin/rails hyrax:default_admin_set:create`

5. create default work type
`rails generate hyrax:work Work`

6. Have fun!


## Installation Notes

* uses [Ruby 2.4.2](https://www.ruby-lang.org) (managed by RVM)
* uses [Rails 5.1.4](http://rubyonrails.org/)
* includes a pre-generated gemset named rdr which lives in the root of the project


## Solr and Fedora

* [SOLR](https://github.com/apache/lucene-solr) should be running on [:8983](http://localhost:8983)
* [Fedora](https://github.com/fcrepo4/fcrepo4) should be running on [:8984](http://localhost:8984)
* Solr and Fedora now run individually (so we don't need to run rake tasks) see [Run the wrappers](https://github.com/samvera/hyrax/wiki/Hyrax-Development-Guide#run-the-wrappers).



## References

This is based on the [Samvera Hyrax](https://github.com/samvera/hyrax#creating-a-hyrax-based-app) installation instructions
