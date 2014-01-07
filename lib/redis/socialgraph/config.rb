require 'singleton'
class Redis
  class Socialgraph
    class Config
      attr_reader :redis

      def initialize(options={})
        url = options[:url] || ""
        if url.empty?
          options[:url] = url_from_env
        end

        @redis = Redis.new client_opts(options)
      end

      private

      def client_opts(options)
        opts = options.dup
        opts[:driver] = opts[:driver] || 'ruby'
        opts
      end

      def url_from_env
        ENV['REDIS_URL'] || ENV['REDISTOGO_URL']
      end

    end
  end
end
