require File.dirname(__FILE__) + '/spec_helper'

describe Merb::Cache do
  describe CacheSpecController, "controller class methods" do
        
    before(:each) do
      Object.class_eval{ remove_const("CacheSpecControllerActionsController") if defined?(CacheSpecControllerActionsController)}
      Object.class_eval("class CacheSpecControllerActionsController < Merb::Controller; def show; 'In Show'; end; end")
      @klass = CacheSpecControllerActionsController
      @controller = @klass.new({})      
    end
    
    it{ @klass.should respond_to(:cache_action) }
    
    it "should setup a cacheing options in the classes cache store" do
      @klass.class_eval <<-Ruby
        cache_action :show
      Ruby
      action_caches = @klass.send(:_action_caches)
      action_caches.should be_a_kind_of(Hash)
      action_caches[:show].should_not be_nil
      action_caches[:show][:proc].should be_nil
      action_caches[:show][:options].should be_empty
    end
    
    it "should add the proc to the action cache store" do
      @klass.class_eval <<-Ruby
        cache_action :show do
          "Stuff"
        end
      Ruby
      ac = @klass.send(:_action_caches)
      ac.should be_a_kind_of(Hash)
      ac[:show][:proc].call.should =="Stuff"
    end
      
    it "should add a before filter for the given action" do
      @klass._before_filters.should be_empty
      @klass.class_eval <<-Ruby
        cache_action :show
      Ruby
      @klass._before_filters.any?{|filter, opts| opts == {:only => ["show"]} }.should be_true      
    end
    
    it "should call _fetch_action_cache in the before_filter" do
      @klass.send(:cache_action, :show)
      @controller = @klass.new({})
      @controller.should_receive(:_fetch_action_cache)
      @controller.should_receive(:_set_action_cache)
      @controller._dispatch("show")      
      @controller.body.should == "In Show"
    end
            
    it{ @klass.should respond_to(:cache_actions)}
    
    it "should add all the actions to via cache_action with the options" do
      pending
      @klass.should_receive(:cache_setup).twice
      @klass.class_eval <<-Ruby
        cache_actions :show, :index, :expire_in => 100 do
          "Stuff"
        end
      Ruby
      ac = @klass.send(:_action_caches)
      ac.should be_a_kind_of(Hash)
      ac[:show][:options].should == {:expire_in => 100}
      ac[:index][:options].should == {:expire_in => 100}
      ac[:show][:proc].call.should == "Stuff"
    end
    
    describe "_fetch_action_cache" do
      it "should implement a _fetch_action_cache private method" do
        @klass.private_instance_methods.should include("_fetch_action_cache")
      end
    end
    
    describe "_set_action_cache" do
      it "should implement a _set_action_cache private method" do
        @klass.private_instance_methods.should include("_set_action_cache")      
      end
    end
    
  end

  describe CacheSpecController, "controller instance methods" do
    
    before(:all) do
      Merb::Cache.setup_default
      @controller = CacheSpecController.new({})
      
      @route_params = {:controller => "My::Controller", :action => "show", :id => 4}
      @get_params = {:search => "some search params"}
      @controller.stub!(:params).and_return(@route_params.merge(@get_params))
    end
    
    it{ @controller.should respond_to(:expire_action)}
    
    it{ @controller.should respond_to(:expire_actions)}
    
    it{ @controller.should respond_to(:cached_action?)}
    
    it "should call the call the base key path on the controller class" do
      pending
      @controller.class.should
      @controller.cache_key.should_not be_nil
      @controller.cache_key
    end
    
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
    
    describe "get method" do
      it{ @controller.should respond_to(:get)}
      
      it "should pass the call through to te cache 'get'" do
        @cache.should_receive(:get).with("key").and_return "key"
        @controller.get("key")      
      end
      
      it "should pass the call through to the custom cache 'get'" do
        @custom_cache.should_receive(:get).with("key").and_return "key"
        @cache.should_not_receive(:get)
        @controller.get("key", :custom_cache)
      end       
    end
    
    describe "put method" do
      it{ @controller.should respond_to(:put)}
      
      it "should pass the put method on to the default cache" do
        @cache.should_receive(:put).with("key", "value", an_instance_of(Integer))
        @controller.put("key", "value", 1)
      end
      
      it "should pass the put method to the custom cache" do
        @custom_cache.should_receive(:put).with("key", "value", an_instance_of(Integer))
        @controller.put("key", "value", 1, :custom_cache)
      end
      
      it "should cahnge the expiry from minutes to seconds" do
        expiry = mock("expiry")
        expiry.should_receive(:*).with(60).and_return(120)
        @cache.should_receive(:put).with("key", "value", 120)
        @controller.put("key", "value", expiry)        
      end
      
    end
    
    describe "cached? method" do
      it{ @controller.should respond_to(:cached?) }
      
      it "should pass the onto the cached? method of the default store" do
        @cache.should_receive(:cached?).with("key").and_return true
        @controller.cached?("key")
      end
      
      it "should pass the onto the cached? method of the custom store" do
        @custom_cache.should_receive(:cached?).with("key").and_return true
        @controller.cached?("key", :custom_cache)
      end
    end
    
    describe "expire! method" do
      it{ @controller.should respond_to(:expire!)}
      
      it "should pass the call the default stores expire! method" do
        @cache.should_receive(:expire!).with("key").and_return true
        @controller.expire!("key")
      end
      
      it "should pass the call the custom stores expire! method" do
        @custom_cache.should_receive(:expire!).with("key").and_return true
        @controller.expire!("key", :custom_cache)
      end
    end
    
  end

end