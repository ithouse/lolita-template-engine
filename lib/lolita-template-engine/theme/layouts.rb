module Lolita
  module TemplateEngine
    class Theme
      
      class Layouts
        include Enumerable
        attr_reader :theme

        def initialize(theme)
          @theme = theme
          @layouts = {}
        end

        def path
          @theme.paths.layouts
        end

        def layout(name)
          self.layouts[name.to_sym]
        end

        def [](name)
          self.layouts[name]
        end

        def layouts
          load_layouts
          @layouts
        end

        def names
          self.layouts.keys.map(&:to_s)
        end

        def each
          self.layouts.each do |name,layout|
            yield name, layout
          end
        end

        private

        def load_layouts
          unless @loaded
            Dir[File.join(self.path,"*")].each do |path|
              unless File.directory?(path)
                file_name = ::File.basename(path)
                file_name = file_name.split(".").first
                @layouts[file_name.to_sym] = Layout.new(path,file_name)
              end
            end
            @loaded = true
          end
        end
      end

      class Layout
        attr_reader :name, :human_name, :path

        def initialize(path,name=nil)
          @name = name
          @path = path
          raise ArgumentError, "Bad path for layout: #{@path}" if @path.blank? || !File.exist?(@path)
          if @name.blank?
            @name = ::File.basename(path).split(".").first
          end
          @human_name = @name.humanize
        end

        def placeholders 
          @placeholders ||=Placeholders.new(self)
        end
      end
      
    end
  end
end