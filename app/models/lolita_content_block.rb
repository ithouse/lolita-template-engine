class LolitaContentBlock < ActiveRecord::Base
  include Lolita::Configuration
  has_many :layout_configurations, :class_name => "LolitaLayoutConfiguration", :dependent => :destroy
  has_many :layouts, :through => :layout_configurations, :class_name => "LolitaLayout"
  lolita
end