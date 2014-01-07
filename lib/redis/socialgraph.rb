class Redis
  class Socialgraph

    def self.config(&block)
      if block_given?
        block.call(Socialgraph::Config)
      else
        Socialgraph::Config
      end
    end

    def self.client
      Socialgraph::Client.instance
    end

    def self.method_missing(meth, *args, &block)
      client.send(meth,*args,&block)
    end
  end
end
