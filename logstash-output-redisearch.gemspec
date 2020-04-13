Gem::Specification.new do |s|
  s.name          = 'logstash-output-redisearch'
  s.version       = '0.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Sends event to Redisearch'
  s.description   = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  # s.homepage      = 'Put your plugin''s website or public repo URL here.'
  s.authors       = ['']
  s.email         = ''
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency "logstash-codec-plain"
  s.add_runtime_dependency 'logstash-codec-json'
  s.add_runtime_dependency 'redis', '~> 4'
  s.add_runtime_dependency 'redisearch-rb'
  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'flores'
  
end
