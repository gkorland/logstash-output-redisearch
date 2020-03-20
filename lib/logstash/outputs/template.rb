require 'json'
require 'redisearch-rb'
require 'time'
require 'redis'

class Index
    def initialize(params)
        begin
            @rs = nil
            @redis = Redis.new(host: params["host"], port: params["port"])
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

    def update_index(fields)
        begin
            @redis.call('FT.ALTER',@idx,'SCHEMA','ADD', *fields)
        rescue => e
            @logger.debug("Something went wrong in index altertion",e)
        end
    end

    def checkfields(event_fields)
       default_fields = []
       extrafields = {}
       idx_info=@rs.info()
       idx_info['fields'].each { |d| default_fields.append(d[0])}
       event_fields.each { |field|
            if not default_fields.include? field
                puts field
                extrafields[field] = "TEXT"
            end
        }

        unless extrafields.empty?
            update_index(extrafields)
        end
    end
end
