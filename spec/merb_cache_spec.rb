require File.dirname(__FILE__) + '/spec_helper'

# Stitch the specs together
require File.join(File.dirname(__FILE__), 'controller_spec')
require File.join(File.dirname(__FILE__), 'action_cache_spec')

# I refuse to spell initialisation with a z, this is me; taking it back for the rest of us.
describe "merb-cache initialisation" do
  it "should default to memcached cache store"
  it "should error when an incorrect configuation value is mapped to the cache store"
  it "should throw Merb::Cache:Store::NotFound for named cache stores that do not exist"
end

describe "returned caches" do
  it "should return the format it was stored in"
  it "should only cache 200 responses"
end