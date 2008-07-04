require File.dirname(__FILE__) + '/spec_helper'

describe Merb::Cache::ControllerCacheProxy do
  
  before(:each) do
    Merb.stub!(:root).and_return("MERB_ROOT")
    @controller = CacheSpecController.new({})
    @controller.stub!(:action_name).and_return("index")
    @op = Merb::Cache::ControllerCacheProxy.new( @controller )
    @controller_name = CacheSpecController.name.snake_case
  end
  
  describe "key_base" do
    
    it{ @op.should respond_to(:key_base) }
    
    it "should have a default key base" do
      @op.key_base.should == "MERB_ROOT/cache/#{@controller_name}/#{@controller.action_name}"
    end
    
    it "should get the key_base if set" do
      @op.key_base = "my base key"
      @op.key_base.should == "my base key"
    end
    
    it "should be set through the initialize when given as an option" do
      op = Merb::Cache::ControllerCacheProxy.new( @controller, :key_base => "the_key_base" )
      op.key_base.should == "the_key_base"
    end
    
  end
  
  describe "key_params" do
    it{ @op.should respond_to(:key_params) }
    
    it "should get the key_params default from the cache store if not set"
    it "should get the key_params from the op if set"
    it "should be set through the initialize when given as an option"
  end
  
  describe "key_id_params" do
    it{ @op.should respond_to(:key_id_params) }
    
    it "should get the key_id_params default from the cache store if not set"
    it "should get the key_id_params from the op if set"
    it "should be set through the initialize when given as an option"
  end
  
end