class LolitaLayoutUrl < ActiveRecord::Base
  belongs_to :lolita_layout, :class_name => "LolitaLayout"

  def self.recognize(themes,request)
    by_themes(themes).by_path(request).first
  end

  def self.by_themes themes
    where(:lolita_layout_id => themes.map(&:id))
  end

  def self.by_path(request)
    urls = self.arel_table
    r_path = request.path == "" ? "/" : request.path
    exact_match = urls[:path].eq(r_path).or(urls[:path].eq(request.url))
    path_match = exact_match.or(controller_action_match(request,urls))
    self.where(path_match)
  end

  def self.controller_action_match(request,urls)
    controller_match = urls[:controller].eq(request.params[:controller])
    action_match = urls[:action].eq(request.params[:action]).or(urls[:action].eq(nil))
    action_match = controller_match.and(action_match)
    action_match
  end

end