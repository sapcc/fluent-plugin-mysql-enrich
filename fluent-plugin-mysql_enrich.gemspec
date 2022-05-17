# -*- encoding: utf-8 -*-
# $:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-mysql_enrich"
  spec.version       = "0.0.2"
  spec.authors       = ["Ivo Gosemann"]
  spec.email         = ["ivo.gosemann@sap.com"]

  spec.summary       = "A Fluent filter plugin to enrich a record with multiple columns from a MySQL table"
  spec.description   = "The MySQL table is cached locally and the lookups are perfomed based on a key present in both the table and the record. The columns to be used for the enrichment are specified in the config."
  spec.homepage      = "https://github.com/sapcc/filter_mysql_enrich/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd", "~> 1.10"
  spec.add_runtime_dependency "mysql2", "~> 0.5.3"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
end
