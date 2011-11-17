module Lolita
  module TemplateEngine
    class Theme

      attr_reader :name,:human_name,:path, :paths
      def initialize(path)
        raise ArgumentError, "Path not found" unless File.directory?(path.to_s)
        @path = path
        @name = path.split("/").last
        @human_name = @name.humanize
        define_path_set
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
            method_name = method_name.to_s.match(/\=$/) ? method_name.to_s.gsub("=","") : method_name
            if args && args.empty? && self.keys.include?(method_name.to_sym)
              self[method_name.to_sym]
            elsif args && args.any?
              self[method_name.to_sym] = args[0].to_s
            end
          end
        end
        @paths.layouts = ::File.join(path,"views","layouts",@name)
        raise Lolita::TemplateEngine::Error, "Layouts directory not found in theme (#{@name})" unless File.directory?(@paths.layouts.to_s)
        @paths.content_blocks = ::File.join(path,"views","themes",@name)
        raise Lolita::TemplateEngine::Error, "Content blocks directory not found in theme (#{@name})" unless File.directory?(@paths.content_blocks.to_s)
      end
    end
  end
end