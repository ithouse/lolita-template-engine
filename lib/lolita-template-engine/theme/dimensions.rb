module Lolita
  module TemplateEngine
    class Theme

      module Dimensions
        GRID_WIDTH = 700
        
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
            (cb_dimension.to_f * diff).floor
          else
            cb_dimension
          end
        end
      end

    end
  end
end