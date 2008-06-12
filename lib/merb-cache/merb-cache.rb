# Deps
%w(gzip/gzip).each{|dep| require File.join(File.dirname(__FILE__), '..', 'vendor', dep) }

class Merb::Cache
  module ControllerClassMethods
  end
  
  module ControllerInstanceMethods
  end
end

# Crack open the controller class and include the cache class and instance methods
class Merb
  class Controller
    include Merb::Cache::ControllerClassMethods
    include Merb::Cache::ControllerInstanceMethods
  end
end