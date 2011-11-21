class Lolita::TemplateEngineController < Lolita::RestController
  helper_method :engine_current_theme,:engine_current_layout,:existing_content_blocks, :existing_placeholders

  private

  def engine_current_theme
    @engine_current_theme ||= Lolita.themes.theme(resource.theme_name.to_s)
  end

  def engine_current_layout
    @engine_current_layout ||= engine_current_theme && engine_current_theme.layouts.layout(resource.name.to_s)
  end
  
  def existing_content_blocks
    engine_current_layout && engine_current_theme.content_blocks || []
  end

  def existing_placeholders
    engine_current_layout && engine_current_layout.placeholders || []
  end
end