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
    
  end 

  describe Merb::Cache::ControllerClassMethods do
    
  end
end