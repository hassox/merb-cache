$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

# Deps
require 'merb-core'
require 'merb-action-args'
require File.join(File.dirname(__FILE__), '..', 'lib', 'merb-cache')

# We want logging!
Merb.logger = Merb::Logger.new(File.join(File.dirname(__FILE__), '..', 'log', 'merb_test.log'))

Merb.start :environment => "test", :adapter => "runner"

require "merb-core/test"
Spec::Runner.configure do |config|
  config.include Merb::Test::RequestHelper
end

class DummyStore < Merb::Cache::AbstractStore
  attr_accessor :vault, :options
  
  def initialize(config = {})
    super(config)
    @options = config
    @vault = {}
  end

  def writable?(*args)
    true
  end

  def read(key, parameters = {})
    if @vault.keys.include?(key)
      @vault[key] if @vault[key].last == parameters
    end
  end

  def data(key, parameters = {})
    read(key, parameters)[0] if read(key, parameters)
  end

  def time(key, parameters = {})
    read(key, parameters)[1] if read(key, parameters)
  end

  def conditions(key, parameters = {})
    read(key, parameters)[2] if read(key, parameters)
  end

  def write(key, data = nil, parameters = {}, conditions = {})
    @vault[key] = [data, Time.now, conditions, parameters]
    true
  end

  def fetch(key, parameters = {}, conditions = {}, &blk)
    @vault[[key, parameters]] ||= blk.call
  end

  def exists?(key, parameters = {})
    @vault.has_key? [key, parameters]
  end

  def delete(key, parameters = {})
    @vault.delete([key, parameters]) unless vault[[key, parameters]].nil?
  end

  def delete_all
    @vault = {}
  end
end