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
        lolita_layout.content_blocks_for_placeholder(placeholder) do |cb,cb_config|
          data_method = cb_config.data_method
          if current_theme.presenter.respond_to?(:"#{data_method}")
            locals = {
              :"data_method" => data_method,
              :"#{cb.name}" => current_theme.presenter.send(:"#{data_method}"), 
              :presenter => current_theme.presenter,
            }
          else
            warn "Method #{cb.name} is not defined in #{current_theme.presenter.class}"
          end
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