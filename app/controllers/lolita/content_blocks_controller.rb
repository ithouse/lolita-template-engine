class Lolita::ContentBlocksController < Lolita::RestController

  def index
    self.resource = LolitaLayout.new()
    theme = Lolita.themes.theme(params[:theme_id])
    if theme
      render_component "lolita/template_engine/content_blocks", :display, :content_blocks => theme.content_blocks
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
