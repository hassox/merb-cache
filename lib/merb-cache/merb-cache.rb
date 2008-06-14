# Require components
require 'merb-cache/controller'
require 'merb-cache/cache_store'

# Namespace
class Merb::Cache; end

Merb::BootLoader.before_app_loads do
  # require code that must be loaded before the application
end

Merb::BootLoader.after_app_loads do
  # code that can be required after the application loads
end