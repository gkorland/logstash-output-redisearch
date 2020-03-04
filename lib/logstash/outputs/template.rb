require 'json'
require 'redis'
require 'redisearch-rb'

class Index

    def self.installTemplate(params)
        fields = params['fields']
        host = params['host']
        port = params['port']
        filepath = ::File.expand_path('template.json', ::File.dirname(__FILE__))
        template_data = ::IO.read(filepath)
        data = JSON.load(template_data)
        schema = data['schema']
        fields.each { |field|
           if not schema.keys.include? field
            schema[field] = "TEXT"
           end
        }
        time = Time.new
        redis_client = Redis.new(host: host, port: port)
        index_name = data['index'].sub! '*', time.strftime("%Y-%m-%d")
        rs = RediSearch.new(index_name,redis_client)
        begin
            rs.info()
        rescue 
            rs.create_index(schema)
        end
    return rs
    end

end