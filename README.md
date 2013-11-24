# casino-ldap_authenticator [![Build Status](https://travis-ci.org/rbCAS/casino-ldap_authenticator.png?branch=master)](https://travis-ci.org/rbCAS/casino-ldap_authenticator) [![Coverage Status](https://coveralls.io/repos/rbCAS/casino-ldap_authenticator/badge.png)](https://coveralls.io/r/rbCAS/casino-ldap_authenticator)

Provides mechanism to use LDAP as an authenticator for [CASino](https://github.com/rbCAS/CASino).

To use the LDAP authenticator, configure it in your cas.yml:

    authenticators:
      my_company_ldap:
        authenticator: "LDAP"
        options:
          host: "localhost"
          port: 636
          base: "ou=people,dc=example,dc=com"
          username_attribute: "uid"
          encryption: "simple_tls"
          # optional, credentials to perform user lookup:
          admin_user: "cn=admin,dc=example,dc=com"
          admin_password: "password"
          extra_attributes:
            email: "mail"
            fullname: "displayname"

## Contributing to casino-ldap_authenticator

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Nils Caspar. See LICENSE.txt
for further details.
