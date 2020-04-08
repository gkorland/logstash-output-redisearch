require 'json'
require 'redisearch-rb'
require 'time'
require 'redis'

class Index
    def initialize(params)
        begin
            @rs = nil
            @redis = Redis.new(
                host: params["host"], 
                port: params["port"],
                ssl: params["ssl"], 
                password:params["password"])
                
            filepath = ::File.expand_path('template.json', ::File.dirname(__FILE__))
            template_data = ::IO.read(filepath)
            data = JSON.load(template_data)
            @schema = data['schema']

            if params["index"] == nil
                time = Time.new
                @idx = data['index'].sub! '*', time.strftime("%Y-%m-%d")
                @rs = RediSearch.new(@idx,@redis)
            else
                @rs = RediSearch.new(params["index"],@redis)
            end
        rescue => e
            @logger.debug("Error in initialization",e)
        end
    end

    def default_index()
        begin
            @rs.info()
        rescue
            @rs.create_index(@schema)
        end
        return @rs
    end

end
