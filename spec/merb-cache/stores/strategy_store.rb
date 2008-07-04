require File.dirname(__FILE__) + '/../../spec_helper'

describe Merb::Cache::StrategyStore do
  shared_examples_for 'all strategy stores' do
    it_should_behave_like 'all stores'

    describe ".contextualize" do
      it "should return a subclass of itself" do
        subclass = @klass.contextualize(Class.new(Merb::Cache::AbstractStore))
        subclass.superclass.should  == @klass
      end

      it "should set the context_classes_or_names attributes" do
        subclass = @klass.contextualize(context_class = Class.new(Merb::Cache::AbstractStore))
        subclass.context_classes_or_names.first.should == context_class
      end
    end

    describe ".[]" do
      it "should be an alias to contextualize" do
        @klass[Class.new(Merb::Cache::AbstractStore)]
      end
    end

    describe "#initialize" do
      it "should create an instance of the any context classes" do
        config = {}

        subclass = @klass.contextualize(context_class = Class.new(Merb::Cache::AbstractStore))
        context_class.should_receive(:new).with(config)
        subclass.new(config)
      end

      it "should lookup the instance of any context names" do
        Merb::Cache.setup(:foo, Class.new(Merb::Cache::AbstractStore))
        subclass = @klass.contextualize(:foo)
        Merb::Cache.should_receive(:[]).with(:foo)
        subclass.new({})
      end
    end

    describe "#clone" do
      it "should clone each context instance" do
        subclass = @klass.contextualize(context_class = Class.new(Merb::Cache::AbstractStore))
        instance = mock(:instance)
        context_class.should_receive(:new).and_return(instance)
        instance.should_receive(:clone)

        subclass.new.clone
      end
    end
  end
end