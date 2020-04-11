require 'json'
require 'redisearch-rb'
require 'time'
require 'redis'

# 
class Index
    def initialize(params)
        begin
            @rs = nil
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

            @rs = RediSearch.new(@idx_name,@redis)

        rescue => e
            @logger.debug("Exception in Index initialization",e)
        end
    end

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

    def connect()
        begin
            @rs.info()
        rescue
            @schema = @template_data['schema']
            @rs.create_index(@schema)
        end
        return @rs
    end

end
