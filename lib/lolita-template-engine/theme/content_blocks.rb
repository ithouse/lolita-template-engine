module Lolita
  module TemplateEngine
    class Theme
      
      class ContentBlocks
        include Enumerable

        attr_reader :theme

        def initialize(theme)
          @theme = theme
          @content_blocks = {}
        end

        def each
          self.content_blocks.each do |name,cb|
            yield name,cb
          end
        end

        def path
          theme.paths.content_blocks
        end

        def content_blocks
          load_content_blocks
          @content_blocks
        end

        def names
          self.content_blocks.keys.map(&:to_s)
        end

        def [](name)
          self.content_blocks[name]
        end

        def content_block(name)
          self.content_blocks[name.to_sym]
        end

        private

        def load_content_blocks
          unless @loaded
            Dir[File.join(self.path,"*")].each do |path|
              unless File.directory?(path)
                file_name = ::File.basename(path)
                file_name = file_name.split(".").first.gsub(/^_/,"")
                @content_blocks[file_name.to_sym] = ContentBlock.new(path,file_name, self)
              end
            end
            @loaded = true
          end
        end

      end

      class ContentBlock

        attr_reader :name,:single, :path
        GRID_WIDTH = 700

        def initialize(path,name = nil,content_blocks = nil)
          @path = path
          @content_blocks = content_blocks
          load_attributes
          raise ArgumentError, "Bad path for content block: #{@path}" unless File.exist?(@path)
          if @name.blank?
            @name = name || ::File.basename(path).split(".").first.gsub(/^_/,"")
          end
          @width = @width && @width.to_i
          @height = @height && @height.to_i
          @single = @single == "true" ? true : false

          unless @width && @height
            raise ArgumentError, "Dimensions must be specified through 'data-width' and 'data-height' in content block file (#{@path})"
          end
        end

        def width(layout = nil)
          if layout
            relative_dimension(:width,layout)
          else
            @width
          end
        end

        def height(layout = nil)
          if layout
            relative_dimension(:height,layout)
          else
            @height
          end
        end

        def relative_dimension(dimension,layout)
          l_dimension = layout.send(dimension)
          cb_dimension = instance_variable_get(:"@#{dimension}")
          if l_dimension.to_i > 0 
            diff = GRID_WIDTH.to_f / layout.send(:width)
            cb_dimension / diff
          else
            cb_dimension
          end
        end

        def view_path
          File.join("/","themes",@content_blocks.theme.name,@name)
        end

        private

        def load_attributes
          
          f_processor = FileProcessor.new(self.path, "content-block", :custom_keys => [:single], :singular => true)
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