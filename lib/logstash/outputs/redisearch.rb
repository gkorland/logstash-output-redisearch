# encoding: utf-8
require "logstash/outputs/base"
require 'redisearch-rb'
require 'redis'
require 'json'
# An redisearch output that does nothing.
class LogStash::Outputs::Redisearch < LogStash::Outputs::Base

  config_name "redisearch"
  default :codec, "json"
  
  config :host, :validate => :string, :default => "127.0.0.1"
  config :port, :validate => :number, :default => 6379
  config :key, :validate => :string, :required => true
  config :index, :validate => :string, :default => 'test_index'
  
  public
  def register
    @redis_client = Redis.new(host: @host, port: @port)
    @redis_client.flushdb
    @redisearch_client = RediSearch.new(@index, @redis_client)
    @schema = [
      'message', 'TEXT'
    ]
    @count = 1
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
    key = event.sprintf(@key)
    begin
      doc = JSON.parse(payload)
      id = key+@count.to_s
      status=@redisearch_client.add_doc(id,doc)
      @logger.info("Inserted Successfully") if status == "OK"
      @count += 1 
    rescue => e
      @logger.warn("Failed to send event to Redisearch", :event => event,
                   :exception => e,
                   :backtrace => e.backtrace)
      sleep @reconnect_interval
      retry
    end
  end
end # class LogStash::Outputs::Redisearch
