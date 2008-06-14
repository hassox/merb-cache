require File.dirname(__FILE__) + '/spec_helper'

# Stitch the specs together
Dir.glob("*_spec.rb").each do |r|
  require File.join(File.dirname(__FILE__), r)
end

# I refuse to spell initialisation with a z, this is me; taking it back for the rest of us.
describe "merb-cache initialisation" do
  it "should default to memcached cache store" do
    @cache = Merb::Cache::Store.new
    @cache.config[:store].should eql "memcached"
  end
  
  it "should error when an incorrect configuation value is mapped to the cache store"
  
  it "should raise Merb::Cache:Store::NotFound for named cache stores that do not exist" do
    Merb::Plugins.config[:merb_cache] = {
      :store => 'fail'
    }
    lambda { Merb::Cache::Store.new }.should raise_error Merb::Cache::Store::NotFound
  end
  
  it "should raise Merb::Cache::Store::BadConfiguration when a invalid config is used" do
    Merb::Plugins.config[:merb_cache] = {
      :fail => 'badconfigoptions'
    }
    lambda { Merb::Cache::Store.new }.should raise_error Merb::Cache::Store::BadConfiguration
  end
end

describe "returned caches" do
  it "should return the format it was stored in"
  it "should only cache 200 responses"
end

describe "cache stores" do
  it "should respond to :get"
  it "should respond to :put"
end