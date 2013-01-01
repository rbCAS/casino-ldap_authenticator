# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'casino_core/authenticator/ldap/version'

Gem::Specification.new do |s|
  s.name        = 'casino_core-authenticator-ldap'
  s.version     = CASinoCore::Authenticator::LDAP::VERSION
  s.authors     = ['Nils Caspar']
  s.email       = ['ncaspar@me.com']
  s.homepage    = 'http://rbcas.org/'
  s.license     = 'MIT'
  s.summary     = 'Provides mechanism to use LDAP as an authenticator for CASinoCore.'
  s.description = 'This gem can be used to allow the CASinoCore backend to authenticate against an LDAP server.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'simplecov', '~> 0.7'

  s.add_runtime_dependency 'net-ldap', '~> 0.3'
  s.add_runtime_dependency 'casino_core', '~> 1.0'
end
