class LolitaLayout < ActiveRecord::Base
  include Lolita::Configuration

  has_many :layout_configurations, :class_name => "LolitaLayoutConfiguration", :dependent => :destroy
  has_many :content_blocks, :through => :layout_configurations, :class_name => "LolitaContentBlock"
  has_many :urls, :class_name => "LolitaLayoutUrl", :dependent => :destroy

  validates :name, :theme, :presence => true

  lolita
end