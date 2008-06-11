# make sure we're running inside Merb
if defined?(Merb::Plugins)

  #Merb::Plugins.config[:merb_cache] = {
    
  #}
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
  #Merb::Plugins.add_rakefiles "merb-cache/merbtasks"
  
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
end