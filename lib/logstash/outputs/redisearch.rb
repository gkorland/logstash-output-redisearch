# encoding: utf-8
require "logstash/outputs/base"
require 'redisearch-rb'
require 'redis'
require 'json'

# An redisearch output will store data into Redisearch.
class LogStash::Outputs::Redisearch < LogStash::Outputs::Base

  config_name "redisearch"
  default :codec, "json"
  
  config :host, :validate => :string, :default => "127.0.0.1"
  config :port, :validate => :number, :default => 6379
  config :index, :validate => :string, :default => 'test_index'
  config :schema, :validate => :array, :default => ['message','TEXT']
  
  public
  def register
    @redis_client = Redis.new(host: @host, port: @port)
    @redis_client.flushdb
    @redisearch_client = RediSearch.new(@index, @redis_client)
    @redisearch_client.create_index(@schema)
    @codec.on_event(&method(:send_to_redisearch))

  end # def register

  public
  def receive(event)
    begin
      @codec.encode(event)
    rescue StandardError => e
      @logger.warn("Error encoding event", :exception => e,
                   :event => event)
    end
  end # def event

  def send_to_redisearch(event, payload)
    begin
      doc = JSON.parse(payload)
      id = rand(2**0..2**63)
      status=@redisearch_client.add_doc(id,doc)
      @logger.info("Inserted Successfully") if status == "OK"
    rescue => e
      @logger.warn("Failed to send event to Redisearch", :event => event,
                   :exception => e,
                   :backtrace => e.backtrace)
      sleep @reconnect_interval
      retry
    end
  end
end # class LogStash::Outputs::Redisearch
