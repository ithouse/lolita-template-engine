module Lolita
  module TemplateEngineHelper

    def controllers_and_actions
      unless @controllers_and_actions 
        path = File.join(Rails.root,Rails.application.paths["app/controllers"],"*")
        @controllers_and_actions = {}
        Dir[path].each{|name| 
          unless File.directory?(name)
            c_name = File.basename(name).split(".").first.camelize
            unless ["ApplicationController"].include?(c_name)
              a_methods = c_name.constantize.action_methods.reject{|met| met.to_s.match(/^_/)}
              @controllers_and_actions[c_name.gsub("Controller","")] = a_methods.sort
            end
          end
        }.compact
      end
      @controllers_and_actions
    end

    def controllers_options_for_select(current = nil)
      options_for_select(controllers_and_actions.keys.sort.map{|name| [name,name]} || [],current)
    end

    def actions_options_for_select(contr = nil,c_action = nil)
      actions = controllers_and_actions[contr] || []
      options_for_select(actions,c_action)
    end
  end
end