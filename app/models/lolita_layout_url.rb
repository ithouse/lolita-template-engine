class LolitaLayoutUrl < ActiveRecord::Base
  belongs_to :lolita_layout, :class_name => "LolitaLayout"
  validates :path, :presence => true, :if => Proc.new{|rec| rec.controller.blank?}
  validates :controller, :presence => true, :if => Proc.new{|rec| rec.path.blank?}

  def self.recognize(themes,request)
    by_path(themes,request)
  end

  def self.by_themes themes
    where(:lolita_layout_id => themes.map(&:id))
  end

  def self.by_path(themes,request)
    r_path = request.path == "" ? "/" : request.path
    layout_url = self.where(:path => r_path).by_themes(themes).first
    layout_url ||= self.where("controller = ? AND action=?",request.params[:controller].to_s.camelize,request.params[:action]).by_themes(themes).first
    layout_url ||= self.where(:controller => request.params[:controller].to_s.camelize, :action=>"").by_themes(themes).first
    layout_url
  end

end