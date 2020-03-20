# encoding: utf-8
# require "logstash/outputs/template"
require "logstash/outputs/template"
require "logstash/outputs/base"
require 'redisearch-rb'
require 'json'
require 'time'
# An redisearch output will store data into Redisearch.
class LogStash::Outputs::Redisearch < LogStash::Outputs::Base

  config_name "redisearch"
  default :codec, "json"

  config :host, :validate => :string, :default => "127.0.0.1"
  config :port, :validate => :number, :default => 6379
  config :index, :validate => :string, :default => nil

  public
  def register
    params = {"host"=>@host,"port"=>@port,"index"=>@index}
    @idx = Index.new(params)
    @redisearch_client = @idx.default_index()
    @template_update = false
    @codec.on_event(&method(:send_to_redisearch))
  end # def register

  public
  def receive(event)
    begin
      event_data = event.to_hash
      @idx.checkfields(event_data.keys)
      @codec.encode(event)
    rescue StandardError => e
      @logger.warn("Error encoding event", :exception => e,
                   :event => event)
    end
  end # def event

  def send_to_redisearch(event, payload)
    begin
      doc = JSON.parse(payload)
      doc['@timestamp'] = Time.parse(doc['@timestamp']).to_i
      id = rand(2**0..2**63)
      status=@redisearch_client.add_doc(id,doc)
      @logger.info("Event inserted successfully") if status == "OK"
    rescue => e
      @logger.warn("Failed to send event to Redisearch", :event => event,
                   :exception => e,
                   :backtrace => e.backtrace)
      sleep @reconnect_interval
      retry
    end
  end
end # class LogStash::Outputs::Redisearch