class Lolita::LayoutsController < ApplicationController
  include Lolita::ControllerAdditions
  before_filter :authenticate_lolita_user!
  helper Lolita::TemplateEngineHelper
  
  layout "lolita/application"

  def new
    @layout = LolitaLayout.new
    render :action => "form"
  end

  def edit
    @layout = LolitaLayout.find(params[:id])
    render :text => "ok"
  end

  private

  def is_lolita_resource?
    true
  end
 
end