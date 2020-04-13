require 'json'
require 'redisearch-rb'
require 'time'
require 'redis'
require 'securerandom'
require 'base64'

# Redisearch index management
class Index
    # initialize and create redis instance using params value
    def initialize(params)
        begin

            @template_data = read_template()
            @redis = Redis.new(
                host: params["host"], 
                port: params["port"],
                ssl: params["ssl"], 
                password:params["password"])
            
            if params["index"] == nil
                time = Time.new
                @idx_name = @template_data['index'].sub! '*', time.strftime("%Y-%m-%d")
            else
                @idx_name = params["index"]
            end

        rescue => e
            @logger.debug("Exception in Index initialization",e)
        end
    end


    # Reads json file and returns data
    def read_template()
        begin
            filepath = ::File.expand_path('template.json', ::File.dirname(__FILE__))
            file_data = ::IO.read(filepath)
            data = JSON.load(file_data)
        rescue => e
            @logger.debug("Exception in reading template", e)
        end
        return data
    end

    # Creates redisearch instance using redis instance.
    # Using redisearch instance, connects to index if it is present, else creates a new index
    def connect()
        begin
            @rs = RediSearch.new(@idx_name,@redis)
            @rs.info()
        rescue
            @schema = @template_data['schema']
            @rs.create_index(@schema)
        end
        return @rs
    end

    # Id for each document in redisearch
    def get_id()
        uuid = SecureRandom.uuid
        id = Base64.encode64([ uuid.tr('-', '') ].pack('H*')).gsub(/\=*\n/, '')
        return id
    end
end #Class Index
