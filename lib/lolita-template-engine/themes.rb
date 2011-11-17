module Lolita
  module TemplateEngine
    class Themes

      include Enumerable
      attr_reader :app_root

      def initialize(app_root = nil,silent = false)
        @silent = silent
        @app_root = app_root || default_app_root 
        raise ArgumentError, "No app root given" unless @app_root
        initialize_themes
      end

      def each
        self.themes.each do |name,theme|
          yield name,theme
        end
      end

      def themes
        load_themes
        @themes
      end

      def theme(name)
        self.themes[name.to_sym]
      end

      def names
        self.themes.keys.map(&:to_s)
      end

      def inspect
        names
      end

      def [](value)
        self.themes[value.to_sym]
      end

      def method_missing method_name, *args
        if self.themes.keys.include?(method_name.to_sym)
          self[method_name]
        end
      end

      def themes_paths 
        search_path = "#{@app_root}#{app_root[-1] == "/" ? "" : "/"}*/"
        @themes_paths ||= Dir[search_path]
      end

      def default_app_root
        if defined?(Rails)
          Rails.app_root
        end
      end 

      private

      def load_themes
        unless @loaded
          self.themes_paths.each do |path|
            begin
              theme = Lolita::TemplateEngine::Theme.new(path)
              @themes[theme.name.to_sym] = theme
            rescue Lolita::TemplateEngine::Error => e
              unless @silent
                raise e
              end
            end
          end
          @loaded = true
        end
      end

      def initialize_themes
        @themes = {}
        class << @themes
          def parent_object=(value)
            @parent_object = value
          end

          def method_missing(method_name, *args)
            @parent_object.send(:load_themes)
            if self.keys.include?(method_name.to_sym)
              self[method_name.to_sym]
            end
          end
        end
        @themes.parent_object = self
      end

    end
  end
end