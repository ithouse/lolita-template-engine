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
        if self.current_layout && (!args || args.empty?)
          super({:nothing => true, :layout => true})
        else
          super
        end
      end

      def current_theme=(theme)
        @current_theme = [String,Symbol].include?(theme.class) ? Lolita.themes.theme(theme) : theme
      end

      def current_theme
        @current_theme
      end

      def current_layout
        unless self.respond_to?(:lolita_mapping)
          unless @current_layout
            layout_name = current_theme && find_layout_by_url
            @current_layout = layout_name && current_theme.layouts.layout(layout_name)
          end
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
          self.class.send(:layout, self.current_layout.relative_path)
        end
      end

      def find_layout_by_url
        self.lolita_layout ||= LolitaLayout.recognize_from(current_theme,request)
        lolita_layout && lolita_layout.name
      end

    end
  end
end