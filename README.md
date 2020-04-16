# Logstash Output Plugin

This logstash output plugin is for Redisearch.
Note: Plugin has not been tested with cluster mode.

### 1. Plugin Development and Testing

#### Requirements
* JRuby (Use Ruby Version Manger(RVM))
* JDK
* Git
* bundler
* Redisearch
* Logstash

#### Install requirements
* RVM
```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash
source ~/.rvm/scripts/rvm
```
* JRuby
```bash
rvm install jruby
```

* JDK
```bash
sudo apt install default-jdk
echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac) )))" >> ~/.profile
source ~/.profile
```

* bundler
```bash
gem install bundler
```

* Redisearch
```bash
git clone --recursive https://github.com/RediSearch/RediSearch.git
make build
make run
```

#### Code

- Clone Project
```bash
git clone https://github.com/hashedin/logstash-output-redisearch.git
``` 
- Use JRuby
```bash
rvm use jruby
```

- Install dependencies
```bash
bundle install
```

#### Test

- Run tests

```bash
bundle exec rspec
```

### 2. Running your Plugin in Logstash

* Install Logstash
```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install logstash
sudo /usr/share/logstash/bin/system-install /etc/logstash/startup.options systemd
```

#### Run in a local Logstash

- Build Gemfile

```bash
gem build logstash-output-redisearch.gemspec
```

- Deploy Gemfile to Logstash

```bash
bin/logstash-plugin install /path/to/logstash-output-redisearch-0.1.0.gem
```

- Verify installed plugin
```bash
bin/logstash-plugin list
There should be logstash-output-redisearch
```
#### Start logstash output plugin

- Configuration options

| Name | Description | Type | Default | 
| --- | --- | --- | --- |
| host | Redis-server IP address | string | "127.0.0.1" | 
| port | Redis-server port number | number | 6379 |
| index | Name an index in redisearch | string | "logstash-current-date" |
| batch_events | Max number of events in a buffer before flush | number | 50 |
| batch_timeout | Max interval to pass before flush | number | 5 |
| ssl | SSL authentication | boolean | false |
| password | Password for authentication | password | - |

* Usage
```bash
output {
    redisearch {
   }
}
```
OR

```bash
output {
    redisearch {
        host => '192.168.0.1'
        port => 6379
        index => logstash
        batch_events => 20
        batch_timeout => 2
        ssl => true
        password => "123"
    }
}
```

#### Example

Let's create a logstash pipleline using filebeat as input plugin and redisearch as output plugin:
1. Install filebeat and configure /etc/filebeat/filebeat.yml as following:
- Install filebeat:
```bash
sudo apt-get install filebeat 
```
- Enable filebeat input to read from file:
```bash
filebeat.inputs:
	enabled: true
	paths:
          -  /path/to/logfile
```

- Change filebeat output from elasticsearch to logstash:
```bash
output.logstash:
	hosts: [“localhost:5044”]
```

2. Create a conf file in /etc/logstash/conf.d
```bash
input {
	beats {
		Port => 5044
	}
output {
	redisearch {
}
}
```

3. After configuring, restart logstash and filebeat services and check the data stashing into redisearch.
```bash 
sudo service logstash restart
sudo service filebeat restart
```

#### References

* https://github.com/logstash-plugins/logstash-output-redis : Redis Output Plugin
* https://github.com/logstash-plugins/logstash-output-elasticsearch : Elasticsearch Output Plugin