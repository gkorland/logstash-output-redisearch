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

  # Hostname of rediserver to connect to rediserver.
  config :host, :validate => :string, :default => "127.0.0.1"
  
  # Port number to connect to rediserver
  config :port, :validate => :number, :default => 6379

  # Index name to create or to connect the existing old spec
  config :index, :validate => :string, :default => nil

  # Interval to reconnect if Failure in redis connection 
  config :reconnect_interval, :validate => :number, :default => 1

  # Max number of events to add in a list 
  config :batch_events, :validate => :number, :default => 10

  # Max interval to pass before flush 
  config :batch_timeout, :validate => :number, :default => 2

  # SSL flag for aunthentication
  config :ssl, :validate => :boolean, :default => false

  # Password for aunthentication
  config :password, :validate => :password

  # Method is a constructor to this class. 
  # Used to intialize buffer, redisearch client and also to create a index if it is not present
  public
  def register
    
    buffer_initialize(
      :max_items => @batch_events,
      :max_interval => @batch_timeout,
    )

    params = {
      "host"=>@host,
      "port"=>@port,
      "index"=>@index,
      "ssl"=>@ssl
    }
    if @password
      params = {
              "password"=>@password.value
          }
    end
    @idx = Index.new(params)
    @redisearch_client = @idx.connect()
    @codec.on_event(&method(:send_to_redisearch))
  
  end # def register

  # Method is to receive event and encode it in json format. 
  public
  def receive(event)
    begin
      @codec.encode(event)
    rescue StandardError => e
      @logger.warn("Error encoding event", :exception => e,
                   :event => event)
      sleep @reconnect_interval
      retry
    end
  end # def event
 
  # Method is called from Stud::Buffer when max_items/max_interval is reached
  def flush(events, close=false)
    #buffer_flush should pass here the :final boolean value.
    @redisearch_client.add_docs(events)
    @logger.info("Buffer Inserted Successfully", :length => events.length)
  end

  # Method is called from Stud::Buffer when an error occurs
  def on_flush_error(e)
    @logger.warn("Failed to send backlog of events to Redisearch",
      :exception => e,
      :backtrace => e.backtrace
    )
  end

  # Method is for final bookkeeping and cleanup when plugin thread exit
  def close
      # Force full flush call to ensure that all accumulated messages are flushed.
      buffer_flush(:final => true)
  end

  # Method to assign uuid to each event (formatting event as per document required by redisearch)
  # and to append each event to buffer 
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