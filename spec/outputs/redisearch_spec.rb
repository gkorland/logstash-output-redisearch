# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/redisearch"
require "logstash/codecs/plain"
require "logstash/json"
require "logstash/event"
require "redisearch-rb"
require "flores/random"
require "redis"

describe LogStash::Outputs::Redisearch do

  subject { described_class.new(config) }
    let(:config) {
    {
      "key" => "key",
      "index" => "test"
    }
    }

    let(:event_count) { Flores::Random.integer(0..10000) }
    let(:message) { Flores::Random.text(0..100) }

    before do
      subject.register
      event_count.times do |i|
        event = LogStash::Event.new("sequence" => i, "message" => message)
        subject.receive(event)
      end
      subject.close
    end

    it "search for a text in redisearch" do
        rs = RediSearch.new("test")
        info = rs.search("message")
        puts info
        insist { info.count } == 0
      end
     
    it "count number of docs in redisearch are same as number of events" do
      rs = RediSearch.new("test")
      info = rs.info()
      puts info['num_docs']
      insist { info['num_docs'].to_i } == event_count
    end
end
