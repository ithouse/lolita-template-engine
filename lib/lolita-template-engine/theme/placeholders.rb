module Lolita
  module TemplateEngine
    class Theme

      class Placeholders
        include Enumerable

        attr_reader :layout
        def initialize(layout)
          @placeholders = {}
          @layout = layout
        end

        def placeholders
          load_placeholders
          @placeholders
        end

        def names
          self.placeholders.keys.map(&:to_s)
        end

        def [](name)
          self.placeholders[name]
        end

        def placeholder(name)
          self.placeholders[name.to_sym]
        end

        def each
          self.placeholders.each do |name,placeholder|
            yield name, placeholder
          end
        end

        private

        def load_placeholders
          unless @loaded
            f_processor = FileProcessor.new(layout.path, "placeholder", :custom_keys => [:disabled,:stretch])
            f_processor.process
            f_processor.results.each do |ph_options|
              @placeholders[ph_options[:name].to_sym] = Placeholder.new(ph_options.merge(:placeholders => self))
            end
            @loaded = true
          end
        end

      end

      class Placeholder

        attr_reader :name,:disabled,:stretch,:options, :placeholders, :width, :height

        def initialize(options)
          @placeholders = options[:placeholders]
          @options = options
          set_attributes
          raise ArgumentError, "No name given for placeholder" if @name.blank?
          @width = @width && @width.to_i
          @height = @height && @height.to_i
          @disabled = @disabled.to_s == "true" ? true : false
        end

        def layout
          self.placeholders && self.placeholders.layout
        end

        private

        def set_attributes
          @options.each do |key,value|
            if self.respond_to?(key.to_sym)
              instance_variable_set(:"@#{key}",value)
            end
          end
        end
      end

    end
  end
end