require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/redisearch"
require "redisearch"

describe LogStash::Outputs::Redisearch do

  context "batch of events" do

    let(:config) {
      {
        "batch_events" => 10,
        "batch_timeout" => 1,
       }
    }
    let(:redisearch) { described_class.new(config) }

    it "should call buffer_receive" do
      redisearch.register
      expect(redisearch).to receive(:buffer_receive).exactly(100).times.and_call_original
      expect(redisearch).to receive(:flush).exactly(10).times
      expect(redisearch).not_to receive(:on_flush_error)

      100.times do |i|
        expect{redisearch.receive(LogStash::Event.new({"message" => "test-#{i}"}))}.to_not raise_error
      end
    end
  end
end