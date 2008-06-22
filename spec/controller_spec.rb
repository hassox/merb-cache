require File.dirname(__FILE__) + '/spec_helper'

describe Merb::Cache do
  describe CacheSpecController, "controller class methods" do
    it "should respond to cache_action"
    it "should respond to cache_actions"
  end

  describe CacheSpecController, "controller instance methods" do
    it "should respond to expire_action"
    it "should respond to expire_actions"
    it "should respond to cached_action?"
    it "should be cached"
    it "should not be cached"
  end
  
  describe Merb::Cache::ControllerInstanceMethods do
      
    before(:all) do
      Merb::Cache.setup_default
      Merb::Cache.setup(:custom_cache, :memcached)
      @controller = CacheSpecController.new({})
      @cache = Merb::Cache[:default]
      @custom_cache = Merb::Cache[:custom_cache]
    end
    
    after(:all) do
      @controller = nil
      Merb::Cache.remove_active_cache!(:custom_cache)
    end
    
    describe "cache_get method" do
      it{ @controller.should respond_to(:cache_get)}
      
      it "should pass the call through to te cache 'get'" do
        @cache.should_receive(:get).with("key").and_return "key"
        @controller.cache_get("key")      
      end
      
      it "should pass the call through to the custom cache 'get'" do
        @custom_cache.should_receive(:get).with("key").and_return "key"
        @cache.should_not_receive(:get)
        @controller.cache_get("key", :custom_cache)
      end       
    end
    
    describe "cache_put method" do
      it{ @controller.should respond_to(:cache_put)}
      
      it "should pass the put method on to the default cache" do
        @cache.should_receive(:put).with("key", "value", an_instance_of(Integer))
        @controller.cache_put("key", "value", 1)
      end
      
      it "should pass the put method to the custom cache" do
        @custom_cache.should_receive(:put).with("key", "value", an_instance_of(Integer))
        @controller.cache_put("key", "value", 1, :custom_cache)
      end
      
      it "should cahnge the expiry from minutes to seconds" do
        expiry = mock("expiry")
        expiry.should_receive(:*).with(60).and_return(120)
        @cache.should_receive(:put).with("key", "value", 120)
        @controller.cache_put("key", "value", expiry)        
      end
      
    end
    
    describe "cache_cached? method" do
      it{ @controller.should respond_to(:cache_cached?) }
      
      it "should pass the onto the cached? method of the default store" do
        @cache.should_receive(:cached?).with("key").and_return true
        @controller.cache_cached?("key")
      end
      
      it "should pass the onto the cached? method of the custom store" do
        @custom_cache.should_receive(:cached?).with("key").and_return true
        @controller.cache_cached?("key", :custom_cache)
      end
    end
    
    describe "cache_expire! method" do
      it{ @controller.should respond_to(:cache_expire!)}
      
      it "should pass the call the default stores expire! method" do
        @cache.should_receive(:expire!).with("key").and_return true
        @controller.cache_expire!("key")
      end
      
      it "should pass the call the custom stores expire! method" do
        @custom_cache.should_receive(:expire!).with("key").and_return true
        @controller.cache_expire!("key", :custom_cache)
      end
    end
    
  end

  describe Merb::Cache::ControllerClassMethods do
    
    before(:all) do
      Merb::Cache.setup_default
      @controller = CacheSpecController.new({})
    end
  
    
    
  end
end