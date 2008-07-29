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
      before("_cache_#{action}_before", conditions.only(:if, :unless).merge(:with => [conditions.except(:if, :unless)], :only => action))
      after("_cache_#{action}_after", conditions.only(:if, :unless).merge(:with => [conditions.except(:if, :unless)], :only => action))
      alias_method "_cache_#{action}_before", :_cache_before
      alias_method "_cache_#{action}_after",  :_cache_after
    end

    def eager_cache(trigger_action, target, conditions = {})
      if target.is_a? Array
        target_controller, target_action = *target
        conditions[:controller] = target_controller
      else
        target_action = target
      end

      after("_eager_cache_#{trigger_action}_after", conditions.only(:if, :unless).merge(:with => [conditions.except(:if, :unless)], :only => trigger_action))
      alias_method "_eager_cache_#{trigger_action}_after", :_eager_cache_after
    end
  end

  def fetch_partial(template, opts={}, conditions = {})
    template_id = template.to_s
    if template_id =~ %r{^/}
      template_path = File.dirname(template_id) / "_#{File.basename(template_id)}"
    else
      kontroller = (m = template_id.match(/.*(?=\/)/)) ? m[0] : controller_name
      template_id = "_#{File.basename(template_id)}"
    end

    unused, template_key = _template_for(template_id, opts.delete(:format) || content_type, kontroller, template_path)

    Merb::Cache[_lookup_store(conditions)].fetch(template_key, opts, conditions) { partial(template, opts) }
  end

  def _cache_before(conditions = {})
    if data = Merb::Cache[_lookup_store(conditions)].read(self, _parameters_and_conditions(conditions).first)
      throw(:halt, data)
      @_cache_hit = true
    end
  end

  def _cache_after(conditions = {})
    if Merb::Cache[_lookup_store(conditions)].write(self, nil, *_parameters_and_conditions(conditions))
      @_cache_write = true
    end
  end

  def _eager_cache_after(conditions)
    
  end

  def _lookup_store(conditions)
    conditions[:store] || conditions[:stores] || Merb::Cache.default_store_name
  end

  #ugly, please make me purdy'er
  def _parameters_and_conditions(conditions)
    parameters = {}

    if self.class.respond_to? :action_argument_list
      arguments, defaults = self.class.action_argument_list[action_name]
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