Gem::Specification.new do |s|
  s.name          = 'logstash-output-redisearch'
  s.version       = '0.1.1'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Stash logs in Redisearch'
  s.description   = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.homepage      = 'https://github.com/hashedin/logstash-output-redisearch'
  s.authors       = ['HashedIn Technologies']
  s.email         = 'redis-connectors@hashedin.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency "logstash-codec-plain", '~> 3.0'
  s.add_runtime_dependency 'logstash-codec-json', '~> 3.0'
  s.add_runtime_dependency 'redis', '~> 4'
  s.add_runtime_dependency 'redisearch-rb', '~> 1'
  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'flores'
  
end
