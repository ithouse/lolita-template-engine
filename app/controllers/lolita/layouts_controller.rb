class Lolita::LayoutsController < ApplicationController
  include Lolita::ControllerAdditions
  before_filter :authenticate_lolita_user!
  before_filter :set_current_theme
  helper Lolita::TemplateEngineHelper

  layout "lolita/application"

  def new
    @layout = LolitaLayout.new(:name => "new layout")
    render :action => "form"
  end

  def edit
    @layout = LolitaLayout.find(params[:id])
    render :text => "ok"
  end

  def show
    theme = Lolita.themes.theme(params[:theme_id])
    if theme 
      theme_layout = theme.layouts.layout(params[:id])
      placeholders = theme_layout ? theme_layout.placeholders : []
      render_component "lolita/template_engine/placeholders", :display, :lolita_layout => LolitaLayout.new, :placeholders => placeholders
    else
      render :nothing => true, :layout => false
    end
  end

  private

  def set_current_theme
    @current_theme = nil
  end

  def is_lolita_resource?
    true
  end
 
end