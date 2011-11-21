class LolitaLayoutUrl < ActiveRecord::Base
  belongs_to :lolita_layout, :class_name => "LolitaLayout"

  def self.recognize(themes,request)
    by_themes(themes).by_path(request).first
  end

  def self.by_themes themes
    where(:lolita_layout_id => themes.map(&:id))
  end

  def self.by_path(request)
    urls = self.klass.arel_table
    exact_match = urls[:path].eq(request.path).or(urls[:path].eq(request.url))
    path_match = exact_match.or(controller_action_match(requets,urls))
    urls.where(path_match)
  end

  def self.controller_action_match(request,urls)
    controller_match = urls[:controller].eq(request.params[:controller])
    action_match = urls[:action].eq(params[:action]).or(urls[:action].eq(nil))
    action_match = controller_match.and(action_match)
  end

end