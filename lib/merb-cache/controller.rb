class Merb::Cache
  module ControllerClassMethods
  end
  
  module ControllerInstanceMethods
  end
end

# Crack open the controller class and include the cache class and instance methods
module Merb
  class Controller
    include Merb::Cache::ControllerClassMethods
    include Merb::Cache::ControllerInstanceMethods
  end
end