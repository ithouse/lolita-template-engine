module Lolita
  module TemplateEngineHelper

    def current_theme
      Lolita.themes.theme(resource.theme_name.to_s)
    end

    def current_layout
      current_theme && current_theme.layouts.layout(resource.name.to_s)
    end
    
    def existing_content_blocks
      current_theme && current_theme.content_blocks || []
    end

    def existing_placeholders
      current_layout && current_layout.placeholders || []
    end
  end
end