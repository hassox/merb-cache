module Merb
  module Cache
    class Store      
      attr_accessor :config
  
      class NotFound < StandardError
        def initialize store_details
          super "Cache store not found: #{store_details.inspect}"
        end
      end
  
      class BadConfiguration < StandardError
        def initialize valid_config={}
          super "Bad cache store configuration: Valid example \n #{valid_config.inspect}"
        end
      end
  
      def initialize(options = {})
        name = options.fetch(:store_name, :default)
        @config = self.class.default_config.merge(Merb::Plugins.config[:merb_cache] || {})
        unless @config[:disabled]
          Merb::Cache.setup(name, (@config[:store] || :memcached), @config)
        else
          Merb.logger.info "Merb cache is disabled"
        end
      end
  
      def self.default_config
        @default_config ||= {
          :store => :memcached,
          :host => "127.0.0.1:11211"
        }.freeze
      end
      
      def get(key, store = :default)
        raise NotImplmented
      end
      
      def put(key, data, expiry, store = :default)
        raise NotImplmented
      end
      
      def cached?(key, store = :default)
        raise NotImplmented
      end
      
      def expire!(key, store = :default)
        raise NotImplmented
      end
  
    end # Store
  end # Cache
end # Merb