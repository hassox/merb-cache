# make sure we're running inside Merb
if defined?(Merb::Plugins)
  require "merb-cache" / "cache"
end
