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
                @layouts[file_name.to_sym] = Layout.new(path,self)
              end
            end
            @loaded = true
          end
        end
      end

      class Layout
        
        attr_reader :name, :system_name, :path, :width,:height

        def initialize(path,layouts = nil)
          @path = path
          @layouts = layouts
          raise ArgumentError, "Bad path for layout: #{@path}" if @path.blank? || !File.exist?(@path)
          @system_name = ::File.basename(path).split(".").first
          load_dimensions
          @width = @width && @width.to_i
          @height = @height && @height.to_i
        end

        def placeholders 
          @placeholders ||=Placeholders.new(self)
        end

        def relative_path
          "#{@layouts.theme.name}/#{self.system_name}"
        end

        def human_name
          ::I18n.t("themes.#{@layouts.theme.name}.layouts.#{name}")
        end 

        private

        def load_dimensions
          f_processor = FileProcessor.new(self.path, "layout", :singular => true)
          f_processor.process
          (f_processor.results.first || []).each do |attr,value|
            if self.respond_to?(attr.to_sym)
              instance_variable_set(:"@#{attr}",value)
            end
          end
        end
      end
      
    end
  end
end