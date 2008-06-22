require File.dirname(__FILE__) + '/spec_helper'

# I refuse to spell initialisation with a z, this is me; taking it back for the rest of us.
describe "merb-cache initialisation" do
  it "should default to memcached cache store" do
    @cache = Merb::Cache::Store.new
    @cache.config[:store].should eql(:memcached)
  end
  
  it "should raise Merb::Cache:Store::NotFound for named cache stores that do not exist" do
    Merb::Plugins.config[:merb_cache] = {
      :store => 'fail'
    }
    lambda { Merb::Cache::Store.new }.should raise_error(Merb::Cache::Store::NotFound)
  end
  
  it "should merge the default options when the default options are missing" do
    Merb::Plugins.config[:merb_cache] = {
      :fail => 'badconfigoptions'
    }
    
  end
  
  it "should setup the default" do
    Merb::Cache.remove_active_cache!(:default)
    lambda do
      Merb::Cache[:default]
    end.should raise_error(Merb::Cache::Store::NotFound)
    Merb::Cache.setup_default
    Merb::Cache[:default].should be_a_kind_of(Merb::Cache::Store)    
  end
  
  it "should not overwrite the existing object" do
    Merb::Cache.setup_default
    id = Merb::Cache[:default].object_id
    Merb::Cache.setup_default
    Merb::Cache[:default].object_id.should == id
    
  end
  
  
end

describe "returned caches" do
  it "should return the format it was stored in"
  it "should only cache 200 responses"
end