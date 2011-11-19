module Lolita
  module TemplateEngine
    class Themes

      include Enumerable
      attr_reader :root_path

      def initialize(root_path = nil,silent = false)
        @silent = silent
        @root_path = root_path || default_root_path 
        raise ArgumentError, "No app root given" unless @root_path
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
        self.themes[value]
      end

      def method_missing method_name, *args
        if self.themes.keys.include?(method_name.to_sym)
          self[method_name]
        end
      end

      def themes_paths 
        search_path = "#{@root_path}#{root_path[-1] == "/" ? "" : "/"}*/"
        @themes_paths ||= Dir[search_path]
      end

      def default_root_path
        if defined?(Rails)
          File.join(Rails.root,"app","themes")
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