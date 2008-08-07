require File.dirname(__FILE__) + '/../../spec_helper'

describe Merb::Cache::CacheMixin do
  describe ".cache!" do
    it "should add a before filter for all actions" do
      class CacheAllActionsBeforeCallController < Merb::Controller
        self.should_receive(:before).with(:_cache_before, :with =>{})

        cache!
      end
    end

    it "should add an after filter for all actions" do
      class CacheAllActionsAfterCallController < Merb::Controller
        self.should_receive(:after).with(:_cache_after, :with =>{})

        cache!
      end
    end
  end

  describe ".cache" do
    it "should call .cache_action with each method symbol" do
      class CacheActionsCallController < Merb::Controller
        actions = [:first, :second, :third]

        actions.each do |action|
          self.should_receive(:cache_action).with(action)
        end

        cache *actions
      end
    end

    it "should call .cache_action with the method symbol and conditions hash" do
      class CacheActionConditionsController < Merb::Controller
        self.should_receive(:cache_action).with(:action, :conditions => :hash)

        cache :action, :conditions => :hash
      end
    end
  end

  describe ".cache_action" do
    it "should add the before filter for only the action" do
      class CacheActionBeforeController < Merb::Controller
        self.should_receive(:before).with("_cache_action_before", :with => [{}], :only => :action)

        cache_action(:action)
      end
    end

    it "should add the after filter for only the action" do
      class CacheActionAfterController < Merb::Controller
        self.should_receive(:after).with("_cache_action_after", :with => [{}], :only => :action)

        cache_action(:action)
      end
    end
  end

  before(:each) do
    class TestController < Merb::Controller; end
    @controller = TestController.new(fake_request)
    @controller.stub!(:action_name).and_return :index
  end

  describe "#_lookup_store" do
    it "should use the :store entry from the conditions hash" do
      @controller._lookup_store(:store => :foo_store).should == :foo_store
    end

    it "should use the :stores entry from the conditions hash" do
      @controller._lookup_store(:stores => [:foo_store, :bar_store]).should == [:foo_store, :bar_store]
    end

    it "should default store name if none is supplied in the conditions hash" do
      @controller._lookup_store({}).should == Merb::Cache.default_store_name
    end
  end

  describe "#_parameters_and_conditions" do
    it "should remove the :params entry from the conditions hash" do
      @controller._parameters_and_conditions(:params => [:foo, :bar]).last.should_not include(:params)
    end

    it "should remove the :store entry from the conditions hash" do
      @controller._parameters_and_conditions(:store => :foo_store).last.should_not include(:store)
    end

    it "should remove the :stores entry from the conditions hash" do
      @controller._parameters_and_conditions(:stores => [:foo_store, :bar_store]).last.should_not include(:stores)
    end

    it "should keep an :expires_in entry in the conditions hash" do
      @controller._parameters_and_conditions(:expire_in => 10).last.should include(:expire_in)
    end

    it "should move the :params entry to the parameters array" do
      @controller._parameters_and_conditions(:params => :foo).first.should include(:foo)
    end
  end

  describe "#_set_skip_cache" do
    it "should set @_skip_cache = true" do
      lambda { @controller._set_skip_cache }.should change { @controller.instance_variable_get(:@_skip_cache) }.to(true)
    end
  end
end