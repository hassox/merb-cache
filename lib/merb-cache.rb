# make sure we're running inside Merb
if defined?(Merb::Plugins)
  # Deps
  %w(gzip/gzip).each{|dep| require File.join(File.dirname(__FILE__), '..', 'vendor', dep) }
  
  require 'merb-cache/merb-cache'
end