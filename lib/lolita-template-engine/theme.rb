module Lolita
  module TemplateEngine
    class Theme

      attr_reader :name,:human_name,:path, :paths
      attr_writer :presenter_class
      def initialize(path)
        raise ArgumentError, "Path not found" unless File.directory?(path.to_s)
        @path = path
        @name = path.split("/").last
        define_path_set
      end

      def human_name
        ::I18n.t("themes.#{name}.title")
      end

      def presenter_class
        @presenter_class ||= "::#{self.name.camelize}Presenter".constantize
      end

      def build_presenter *args,&block
        @presenter = self.presenter_class.new(*args,&block)
      end

      def presenter
        @presenter ||= self.presenter_class.new
      end

      def reload_presenter
        @presenter = self.presenter_class.new
      end

      def layouts
        @layouts ||= Layouts.new(self)
      end

      def content_blocks
        @content_blocks ||= ContentBlocks.new(self)
      end

      private

      def define_path_set
        @paths = {}
        class << @paths
          def method_missing method_name, *args
            original_method_name = method_name
            method_name = method_name.to_s.match(/\=$/) ? method_name.to_s.gsub("=","") : method_name
            if args && args.empty? && self.keys.include?(method_name.to_sym)
              self[method_name.to_sym]
            elsif args && args.any? && original_method_name.match(/\=$/)
              self[method_name.to_sym] = args[0].to_s
            end
          end
        end
        @paths.views = ::File.join(path,"views")
        @paths.assets = ::File.join(path,"assets")
        @paths.layouts = ::File.join(path,"views","layouts",@name)
        raise Lolita::TemplateEngine::Error, "Layouts directory not found in theme (#{@name})" unless File.directory?(@paths.layouts.to_s)
        @paths.content_blocks = ::File.join(path,"views","themes",@name)
        raise Lolita::TemplateEngine::Error, "Content blocks directory not found in theme (#{@name})" unless File.directory?(@paths.content_blocks.to_s)
      end
    end
  end
end