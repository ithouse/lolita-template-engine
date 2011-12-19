module Lolita
  module TemplateEngine
    module ViewHelpers

      def placeholder(name)
        current_placeholder = current_layout && current_layout.placeholders.placeholder(name)
        if current_placeholder 
          raw(render_content_blocks(current_placeholder))
        else
          ""
        end
      end

      def render_content_blocks(placeholder)
        result = ""
        locals={}

        lolita_layout.content_blocks_for_placeholder(placeholder) do |cb,cb_config|
          data_method = cb_config.data_method
          unless cb.is_a?(LolitaContentBlock)
            if current_theme.presenter.respond_to?(:"#{data_method}") || instance_variable_get(:"@#{data_method}") 
              locals[:"#{cb.name}"] = instance_variable_get(:"@#{data_method}") || current_theme.presenter.send(:"#{data_method}")
            else
              warn "Method #{cb.name} is not defined in #{current_theme.presenter.class} and there is no instance variable @#{data_method}"
            end
          end

          locals[:"data_method"] = data_method
          locals[:presenter] = current_theme.presenter

          result += if cb.is_a?(LolitaContentBlock)
            if cb.single
              raw("#{cb.body}<div style='clear:both'></div>")
            else
              raw(cb.body)
            end
          else
            render(:partial => cb.view_path, :locals => locals)
          end
        end
        raw(result)
      end

    end
  end
end