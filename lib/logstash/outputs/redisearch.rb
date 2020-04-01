# encoding: utf-8
# require "logstash/outputs/template"
require "logstash/outputs/template"
require "logstash/outputs/base"
require 'redisearch-rb'
require 'securerandom'
require "stud/buffer"
require 'json'
require 'time'
# An redisearch output will store data into Redisearch.
class LogStash::Outputs::Redisearch < LogStash::Outputs::Base
  include Stud::Buffer
  config_name "redisearch"
  default :codec, "json"

  config :host, :validate => :string, :default => "127.0.0.1"
  config :port, :validate => :number, :default => 6379
  config :index, :validate => :string, :default => nil
  config :reconnect_interval, :validate => :number, :default => 1
  config :batch_events, :validate => :number, :default => 10
  config :batch_timeout, :validate => :number, :default => 2

  public
  def register
    buffer_initialize(
      :max_items => @batch_events,
      :max_interval => @batch_timeout,
    )
    params = {"host"=>@host,"port"=>@port,"index"=>@index}
    @idx = Index.new(params)
    @redisearch_client = @idx.default_index()
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
 
  def flush(events, close=false)
    #buffer_flush should pass here the :final boolean value.
    @redisearch_client.add_docs(events)
    @logger.info("Buffer Inserted Successfully", :length => events.length)
  end

  # called from Stud::Buffer#buffer_flush when an error occurs
  def on_flush_error(e)
    @logger.warn("Failed to send backlog of events to Redissearch",
      :exception => e,
      :backtrace => e.backtrace
    )
  end

  def close
      buffer_flush(:final => true)
  end

  def send_to_redisearch(event, payload)
    begin
      doc_data = JSON.parse(payload)
      doc_id = SecureRandom.uuid
      document = [doc_id,doc_data]
      buffer_receive(document)

    rescue => e
      @logger.warn("Failed to send event to Redisearch", :event => event,
                   :exception => e,
                   :backtrace => e.backtrace)
      sleep @reconnect_interval
      retry
    end
  end
end # class LogStash::Outputs::Redisearch