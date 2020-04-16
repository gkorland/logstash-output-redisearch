# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/redisearch"
require "logstash/event"
require "redisearch-rb"
require "flores/random"
require "redis"

describe LogStash::Outputs::Redisearch do
context "to check if events are inserted to redisearch" do
  subject { described_class.new(config) }

    options = {
      "host" => "127.0.0.1",
      "port" => 6379,
      "index" => "test_idx",
    }

    let(:config) {
      options
    }
    let(:event_count) { Flores::Random.integer(0..1000) }
    let(:message) { Flores::Random.text(0..2) }
    redis = Redis.new(host: options["host"], port: options["port"])
    rs = RediSearch.new(options["index"],redis)

    before do
      subject.register
      event_count.times do |i|
        event = LogStash::Event.new("sequence" => i, "message" => message)
        subject.receive(event)
      end
      subject.close
    end

    it "search for a text in redisearch" do
        info = rs.search("message")
        insist { info.count } == 0
    end
     
    it "count number of docs in redisearch are same as number of events" do
      info = rs.info()
      insist { info['num_docs'].to_i } == event_count
    end

  end
end
