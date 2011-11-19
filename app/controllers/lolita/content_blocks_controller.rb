class Lolita::ContentBlocksController < Lolita::RestController

  def index
    theme = Lolita.themes.theme(params[:theme_id])
    if theme
      render_component "lolita/template_engine/content_blocks", :display, :content_blocks => theme.content_blocks
    else
      render :text => "", :layout => false
    end
  end

  private

  def is_lolita_resource?
    true
  end

end
