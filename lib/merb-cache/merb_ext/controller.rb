module Merb::Cache::CacheMixin
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def cache!(conditions = {})
      before(:_cache_before, conditions.only(:if, :unless).merge(:with => conditions.except(:if, :unless)))
      after(:_cache_after, conditions.only(:if, :unless).merge(:with => conditions.except(:if, :unless)))
    end

    def cache(*actions)
      if actions.last.is_a? Hash
        cache_action(*actions)
      else
        actions.each {|a| cache_action(*a)}
      end
    end

    def cache_action(action, conditions = {})
      before("_cache_#{action}_before", conditions.only(:if, :unless).merge(:with => conditions.except(:if, :unless), :only => action))
      after("_cache_#{action}_after", conditions.only(:if, :unless).merge(:with => conditions.except(:if, :unless), :only => action))
      alias_method "_cache_#{action}_before", :_cache_before
      alias_method "_cache_#{action}_after",  :_cache_after
    end
  end

  def _cache_before(conditions = {})
    if data = MerbCache.read(self, conditions)
      throw(:halt, data)
      @_cache_hit = true
    end
  end

  def _cache_after(conditions = {})
    if Merb::Cache.write(self, conditions)
      @_cache_write = true
    end
  end
end