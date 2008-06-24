module Merb
  module Cache
    class ControllerCacheProxy
      attr_accessor :controller, :options
      
      def initialize(controller, opts = {})
        @key_base = opts.fetch(:key_base, Merb.root / "cache" / controller.class.name.to_const_path / controller.action_name)
        @controller = controller
      end
      
      def key_base
        @key_base
      end
      
      def key_base=(base)
        @key_base = base
      end
      
      
      def key_params
      end
      
      def key_id_params
      end
      
      
    end # ObjectCacheProxy
  end # Cache
end # Merb