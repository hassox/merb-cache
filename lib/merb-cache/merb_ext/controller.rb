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
      before("_cache_#{action}_before", conditions.only(:if, :unless).merge(:with => [action, conditions.except(:if, :unless)], :only => action))
      after("_cache_#{action}_after", conditions.only(:if, :unless).merge(:with => [action, conditions.except(:if, :unless)], :only => action))
      alias_method "_cache_#{action}_before", :_cache_before
      alias_method "_cache_#{action}_after",  :_cache_after
    end
  end

  def _cache_before(action, conditions = {})
    if data = Merb::Cache[_lookup_store(conditions)].read(self, _parameters_and_conditions(action, conditions).first)
      throw(:halt, data)
      @_cache_hit = true
    end
  end

  def _cache_after(action, conditions = {})
    if Merb::Cache[conditions[:store] || :default].write(self, nil, *_parameters_and_conditions(action, conditions))
      @_cache_write = true
    end
  end

  def _lookup_store(conditions)
    conditions[:store] || conditions[:stores] || Merb::Cache.default_store_name
  end

  def _parameters_and_conditions(action, conditions)
    parameters = {}
    if self.class.respond_to? :action_argument_list
      arguments, defaults = self.class.action_argument_list[action]
      arguments.inject(parameters) do |parameters, arg|
        if defaults.include?(arg.first)
          parameters[arg.first] = self.params[arg.first] || arg.last
        else
          parameters[arg.first] = self.params[arg.first]
        end
        parameters
      end
    end

    case conditions[:params]
    when Symbol
      parameters[conditions[:params]] = self.params[conditions[:params]]
    when Array
      conditions[:params].each do |param|
        parameters[param] = self.params[param]
      end
    end

    return parameters, conditions.except(:params, :store, :stores)
  end
end