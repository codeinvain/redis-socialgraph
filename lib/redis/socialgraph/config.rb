require 'singleton'
class Redis
  class Socialgraph
    module Config
      class << self
        def redis (options={})
          url = options[:url] || ""
          if url.empty?
            options[:url] = url_from_env
          end

          Redis.new client_opts(options)
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
end
