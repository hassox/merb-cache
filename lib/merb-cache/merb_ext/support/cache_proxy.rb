module Merb
  class Controller
    class AbstractCacheProxy
      attr_accessor :base_key, :param_key, :id_key, :controller
    end
  end
end