Gem::Specification.new do |spec|
  spec.name     = "hubbado-idempotence-sequential"
  spec.version  = "1.0.5"
  spec.authors  = ["Hubbado"]
  spec.email    = ["devs@hubbado.com"]

  spec.summary  = "Idempotence library to handle sequential idempotence pattern in eventide toolkit"
  spec.homepage = "https://www.github.com/hubbado/hubbado-idempotence-sequential"
  spec.license  = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.require_paths = ["lib"]
  spec.files = Dir.glob('{lib}/**/*')

  spec.add_runtime_dependency "evt-messaging"

  spec.add_development_dependency "debug"
  spec.add_development_dependency "hubbado-style"
  spec.add_development_dependency "test_bench"
end
