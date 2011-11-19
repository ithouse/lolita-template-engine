class Lolita::ThemesController < Lolita::RestController

  def show
    @theme = Lolita.themes.theme(params[:id])
  end

  private

  def is_lolita_resource?
    true
  end
end
