#require File.dirname(__FILE__) + '/../../spec_helper'
#
#describe "cache examples" do
#  before(:each) do
#    Merb::Cache.setup(DummyCache)
#  end
#
#  it "should description" do
#    
#  end
#end
#
#describe Merb::Cache::CacheMixin do
#  describe ".cache!" do
#    it "should add a before filter for all actions" do
#      class CacheAllActionsBeforeCallController < Merb::Controller
#        self.should_receive(:before).with(:_cache_before, :with =>{})
#
#        cache!
#      end
#    end
#
#    it "should add an after filter for all actions" do
#      class CacheAllActionsAfterCallController < Merb::Controller
#        self.should_receive(:after).with(:_cache_after, :with =>{})
#
#        cache!
#      end
#    end
#  end
#
#  describe ".cache" do
#    it "should call .cache_action with each method symbol" do
#      class CacheActionsCallController < Merb::Controller
#        actions = [:first, :second, :third]
#
#        actions.each do |action|
#          self.should_receive(:cache_action).with(action)
#        end
#
#        cache *actions
#      end
#    end
#
#    it "should call .cache_action with the method symbol and conditions hash" do
#      class CacheActionConditionsController < Merb::Controller
#        self.should_receive(:cache_action).with(:action, :conditions => :hash)
#
#        cache :action, :conditions => :hash
#      end
#    end
#  end
#
#  describe ".cache_action" do
#    it "should add the before filter for only the action" do
#      class CacheActionBeforeController < Merb::Controller
#        self.should_receive(:before).with("_cache_action_before", :with => {}, :only => :action)
#
#        cache_action(:action)
#      end
#    end
#
#    it "should add the after filter for only the action" do
#      class CacheActionAfterController < Merb::Controller
#        self.should_receive(:after).with("_cache_action_after", :with => {}, :only => :action)
#
#        cache_action(:action)
#      end
#    end
#  end
#end