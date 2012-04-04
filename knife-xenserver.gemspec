# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-xenserver/version"

Gem::Specification.new do |s|
  s.name        = "knife-xenserver"
  s.version     = Knife::XenServer::VERSION
  s.has_rdoc    = true
  s.authors     = ["Sergio Rubio"]
  s.email       = ["rubiojr@frameos.org","rubiojr@frameos.org"]
  s.homepage = "http://github.com/rubiojr/knife-xenserver"
  s.summary = "XenServer Support for Chef's Knife Command"
  s.description = s.summary
  s.extra_rdoc_files = ["README.md", "LICENSE" ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.add_dependency "terminal-table"
  s.add_dependency "chef", ">= 0.10"
  ## Fog 1.3.1 deps. We'll need to remove them
  # when using fog upstream
  s.add_dependency('builder')
  s.add_dependency('excon', '~>0.13.0')
  s.add_dependency('formatador', '~>0.2.0')
  s.add_dependency('multi_json', '~>1.0')
  s.add_dependency('mime-types')
  s.add_dependency('net-scp', '~>1.0.4')
  s.add_dependency('net-ssh', '>=2.1.3')
  s.add_dependency('nokogiri', '~>1.5.0')
  s.add_dependency('ruby-hmac')
  s.require_paths = ["lib"]
end
