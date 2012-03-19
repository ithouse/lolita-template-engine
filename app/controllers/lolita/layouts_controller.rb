class Lolita::LayoutsController < Lolita::TemplateEngineController
  
  def show
    authorization_proxy.authorize!(:create, LolitaLayout)
    self.resource = LolitaLayout.new(:theme_name => params[:theme_id], :name => params[:id])
    if engine_current_theme 
      placeholders = existing_placeholders
      render_component "lolita/template_engine/placeholders", :display, :placeholders => placeholders
    else
      render :nothing => true, :layout => false
    end
  end

  def select
    authorization_proxy.authorize!(:create, LolitaLayout)
    self.resource = LolitaLayout.new(:theme_name => params[:theme_id])
    if engine_current_theme
      render_component "lolita/template_engine/layouts", :select
    else
      render :text => "", :layout => false
    end
  end

  def content_blocks
    authorization_proxy.authorize!(:create,LolitaLayout)
    self.resource = LolitaLayout.new(:theme_name => params[:theme_id], :name => params[:id])
    if engine_current_layout
      render_component "lolita/template_engine/content_blocks", :display, 
        :content_blocks => existing_content_blocks,
        :user_blocks => existing_user_blocks
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

  def resource_class
    LolitaLayout
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