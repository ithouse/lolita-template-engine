module Lolita
  module TemplateEngineHelper

    def themes_for_select
      themes = [[::I18n.t("lolita.template_engine.themes select default"),nil]]
      themes + Lolita.themes.map{|name, theme| [theme.human_name,theme.name]}.sort{|a,b| a[0]<=>b[0]}
    end

    def content_block_html_options(content_block,options={})
      html_options = {}
      if content_block
        if content_block.is_a?(LolitaContentBlock)
          special_classes = content_block.placeholder_name.split(",")
          html_options[:"data-content-block-id"] = content_block.id
        end
        html_class = []
        html_class << (options[:active] ? "active" : "inactive")
        html_class << (special_classes.blank? ? "fit-in-all" : special_classes)
        html_class << "single" if content_block.single

        html_options.merge!({
          :class => html_class.join(" "),
          :"data-name" => content_block.name, 
          :"data-human-name" => content_block.human_name,
          :"data-width" => content_block.width(),
          :"data-height" => content_block.height(),
          :"data-methods" => content_block.human_data_methods
        })
      end
      html_options
    end

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