class Lolita::LayoutsController < Lolita::TemplateEngineController
  
  def new
    self.resource = LolitaLayout.new(params[:layout])
    render :action => "form"
  end

  def edit
    self.resource = LolitaLayout.find(params[:id])
    
    render :action => "form"
  end

  def show
    self.resource = LolitaLayout.new(:theme_name => params[:theme_id], :name => params[:id])
    if engine_current_theme 
      placeholders = engine_current_layout && engine_current_layout.placeholders || []
      render_component "lolita/template_engine/placeholders", :display, :placeholders => placeholders
    else
      render :nothing => true, :layout => false
    end
  end

  def select
    self.resource = LolitaLayout.new(:theme_name => params[:theme_id])
    if engine_current_theme
      render_component "lolita/template_engine/layouts", :select, :theme => engine_current_theme
    end
  end

  def content_blocks
    self.resource = LolitaLayout.new(:theme_name => params[:theme_id], :name => params[:id])
    if engine_current_layout
      render_component "lolita/template_engine/content_blocks", :display, :content_blocks => engine_current_theme.content_blocks
    else
      render :text => "", :layout => false
    end
  end

  def lolita_mapping
    Lolita.mappings[:layout]
  end

  def resource_name
    "lolita_layout"
  end

  private

  def show_form
    self.run(:"after_#{params[:action]}")
    if request.xhr?
      render :action => :form, :layout => false
    else
      render :action => :form
    end
  end
 
end