module Lolita
  module TemplateEngine
    module ControllerHelpers
      extend ActiveSupport::Concern
      included do
        helpers = %w(current_theme current_layout lolita_layout current_theme= lolita_layout=)
        hide_action *helpers
       
        helper_method *helpers
        before_filter :set_current_layout
      end

      def render *args, &block
        if self.current_layout
          super({:layout => current_layout.relative_path, :nothing => true})
        else
          super
        end
      end

      def current_theme=(theme)
        @current_theme = theme
      end

      def current_theme
        @current_theme
      end

      def current_layout
        unless @current_layout
          layout_name = current_theme && find_layout_by_url
          @current_layout = layout_name && current_theme.layouts.layout(layout_name)
        end
        @current_layout
      end

      def lolita_layout
        @lolita_layout
      end

      def lolita_layout=(db_layout)
        @lolita_layout = db_layout
      end

      private

      def set_current_layout
        if self.current_layout
          self.class_eval do
            layout current_layout
          end
        end
      end

      def find_layout_by_url
        self.lolita_layout = LolitaLayout.recognize_from(current_theme,request)
        lolita_layout && lolita_layout.name
      end

    end
  end
end