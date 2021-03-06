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
                new_block = ContentBlock.new(path,file_name, self)
                @content_blocks[new_block.name.to_sym] = new_block
              end
            end
            @loaded = true
          end
        end

      end

      class ContentBlock
        attr_reader :name,:single, :path, :width, :height, :data_methods

        def initialize(path,name = nil,content_blocks = nil)
          @path = path
          @content_blocks = content_blocks
          raise ArgumentError, "Bad path for content block: #{@path}" unless File.exist?(@path)
          load_attributes
          raise Lolita::TemplateEngine::Error, "Meta-information about block not specified. Add 'data-content-block' somewhere in #{@path}" unless @name
          @name = @name.blank? ? (name || ::File.basename(path).split(".").first.gsub(/^_/,"")) : @name
          @width = @width && @width.to_i
          @height = @height && @height.to_i
          @single = @single == "true" ? true : false

          unless @width && @height
            raise ArgumentError, "Dimensions must be specified through 'data-width' and 'data-height' in content block file (#{@path})"
          end
        end

        def human_data_methods
          (data_methods && data_methods.gsub(/\s/,"").split(",") || []).map do |data_method| 
            [::I18n.t("#{translation_path}.data_methods.#{data_method}"), data_method ]
          end.join(",")
        end

        def human_name
          possible_human_name = ::I18n.t("#{translation_path}")
          if possible_human_name.is_a?(Hash) || possible_human_name.to_s.match(/translation missing/)
            "#{::I18n.t("#{translation_path}.title")},#{name}"
          else
            "#{possible_human_name},#{name}"
          end 
        end 

        def view_path
          File.join("themes",@content_blocks.theme.name,@name)
        end

        def translation_path
          "themes.#{@content_blocks.theme.name}.content_blocks.#{name}"
        end

        private


        def load_attributes
          f_processor = FileProcessor.new(self.path, "content-block", :custom_keys => [:single, :methods], :singular => true)
          f_processor.process
          (f_processor.results.first || []).each do |attr,value|
            if attr == :methods
              @data_methods = value
            elsif self.respond_to?(attr.to_sym)
              instance_variable_set(:"@#{attr}",value)
            end
          end
        end

      end
      
    end
  end
end