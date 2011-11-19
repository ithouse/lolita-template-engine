class Lolita::LayoutsController < Lolita::RestController
  helper Lolita::TemplateEngineHelper

  def new
    self.resource = LolitaLayout.new(params[:layout])
    render :action => "form"
  end

  def edit
    self.resource = LolitaLayout.find(params[:id])
    render :action => "form"
  end

  def show
    self.resource = LolitaLayout.new
    theme = Lolita.themes.theme(params[:theme_id])
    if theme 
      theme_layout = theme.layouts.layout(params[:id])
      placeholders = theme_layout ? theme_layout.placeholders : []
      render_component "lolita/template_engine/placeholders", :display, :lolita_layout => LolitaLayout.new, :placeholders => placeholders
    else
      render :nothing => true, :layout => false
    end
  end

  def lolita_mapping
    Lolita.mappings[:layout]
  end

  def resource_name
    "lolita_layout"
  end

  def show_form
    self.run(:"after_#{params[:action]}")
    if request.xhr?
      render :action => :form, :layout => false
    else
      render :action => :form
    end
  end
 
end