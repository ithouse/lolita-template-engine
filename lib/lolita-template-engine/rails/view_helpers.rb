module Lolita
  module TemplateEngine
    module ViewHelpers

      def placeholder(name)
        # unless self.respond_to?(:_lolita_template_engine_view_methods?)
        #   class << self
        #     def _lolita_template_engine_view_methods?
        #       true
        #     end
        #     def method_missing method_name, *args
        #       if self.instance_variables.include?(:"@{method_name}")
        #         instance_variable_get(:"@#{method_name}")
        #       end
        #     end
        #   end
        # end
        current_placeholder = current_layout && current_layout.placeholders.placeholder(name)
        if current_placeholder 
          raw(render_content_blocks(current_placeholder))
        else
          ""
        end
      end

      def render_content_blocks(placeholder)
        result = ""
        lolita_layout.content_blocks_for_placeholder(placeholder).each do |cb|
          if current_theme.presenter.respond_to?(:"#{cb.name}")
            locals = {:"#{cb.name}" => current_theme.presenter.send(:"#{cb.name}")}
          else
            warn "Method #{cb.name} is not defined in #{current_theme.presenter.class}"
          end
          result += if cb.is_a?(LolitaContentBlock)
            raw(cb.body)
          else
            render(:partial => cb.view_path, :locals => locals)
          end
        end
        raw(result)
      end

    end
  end
end