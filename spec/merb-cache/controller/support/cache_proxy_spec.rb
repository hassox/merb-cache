require File.dirname(__FILE__) + '/../../../spec_helper'

describe "Merb::Controller cache proxy" do
  
  describe Merb::Controller do    
    describe "class methods" do
      # cache.page # should use  a PageCacheProxy
      # cache.action # shoudl use an ActionCacheProxy
    end
    
    describe "instance methods" do
      # cache should instantiate a proxy if one doesn't exist
    end    
  end
   
  describe Merb::Controller::AbstractCacheProxy do
    class AProxy < Merb::Controller::AbstractCacheProxy; end
    class AController < Merb::Controller; end
    before(:each) do
      @controller = AController.new({})
      @proxy = AProxy.new
    end 

    describe "controller" do
      it{@proxy.should respond_to(:controller)}
      
      it "should raise an error if there is no controller supplied"
      it "should return the controller"
      it "should attach itself to the controller instance"
    end
    
    describe "base_key" do
      it{@proxy.should respond_to(:base_key)}
      it "should allow you to set the base_key via an option"
      it "should take the base_key as a proc or value"
      it "should pass the controller to the proc"
      it "shoudl be set with a directory object"
      it "shoudl be set with a string"
      it "should be set with an array"
      it "should evaluate to a string"   
      it "should evaluate to a string the return of the block"
    end
    
    describe "param_key" do
      it{@proxy.should respond_to(:param_key)}
      it "shoudl allow you to set the param_key via an option"
      it "should allow the param_key to be set with a proc or value"
      it "should take the param_key as a proc or value"
      it "should pass the controller to the proc"
      it "shoudl be set with a directory object"
      it "shoudl be set with a string"
      it "should be set with an array"
      it "should evaluate to a string"   
      it "should evaluate to a string the return of the block"    
    end
    
    describe "id_key" do
      it{@proxy.should respond_to(:id_key)}
      it "shoudl allow you to set the id_key via an option"
      it "should allow the id_key to be set with a proc or value"
      it "should take the id_key as a proc or value"
      it "should pass the controller to the proc"
      it "shoudl be set with a directory object"
      it "shoudl be set with a string"
      it "should be set with an array"
      it "should evaluate to a string"   
      it "should evaluate to a string the return of the block"
    end

    describe "force_update!" do
      # @controller.cache.force_update!
    end
    
    describe "retain_cache!" do
      # @controller.cache.retain_cache!
    end
    
    describe "expire!" do
      # @controller.cache.expire!(:action, :show, :id => blah)
      # @controller.cache.expire!
      # @controller.cache.expire!(:page, :index)
      # @controller.cache.fragment.expire!(:this => is, :my => :key)
    end
    
    describe "refresh!" do
      # @controller.cache.refresh!(:action, :show, :id => blah)
      # @controller.cache(:my_store).refresh!(:page, :index)      
    end
    
    describe "fragment" do
      # should instantiate a FragmentCacheProxy
      # @controller.cache.fragment.write
      # @controller.cache(:my_frag_cache).fragment.read(key)
    end
      
  end
  
end