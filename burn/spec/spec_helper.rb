$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

# Deps
require 'merb-core'
require File.join(File.dirname(__FILE__), '..', 'lib', 'merb-cache')

# Require a controller to test requests against and check
# methods are included correctly.
require File.join(File.dirname(__FILE__), 'supports', 'controller')

# We want logging!
Merb.logger = Merb::Logger.new(File.join(File.dirname(__FILE__), '..', 'log', 'merb_test.log'))

# We need memcached to run our specs, and it needs to be running. Oh the pain of it all!
require 'memcached'