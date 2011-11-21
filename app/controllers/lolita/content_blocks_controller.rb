class Lolita::ContentBlocksController < Lolita::TemplateEngineController

  def index
    self.resource = LolitaLayout.new(:theme_name => params[:theme_id])
    if engine_current_theme
      render_component "lolita/template_engine/content_blocks", :display, :content_blocks => engine_current_theme.content_blocks
    else
      render :text => "", :layout => false
    end
  end

  private

  def resource_name
    "lolita_layout"
  end

  def is_lolita_resource?
    Lolita.mappings[:layout]
  end

end
