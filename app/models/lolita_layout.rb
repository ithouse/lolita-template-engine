class LolitaLayout < ActiveRecord::Base
  include Lolita::Configuration

  has_many :layout_configurations, :class_name => "LolitaLayoutConfiguration", :dependent => :destroy
  #has_many :content_blocks, :through => :layout_configurations, :class_name => "LolitaContentBlock"
  has_many :urls, :class_name => "LolitaLayoutUrl", :dependent => :destroy

  validates :name, :theme_name, :title, :presence => true

  accepts_nested_attributes_for :layout_configurations, :allow_destroy => true

  lolita

  def theme
    Lolita.themes.theme(self.theme_name.to_s)
  end

  def layout
    self.theme && self.theme.layouts.layout(self.name.to_s)
  end

  def content_blocks
    blocks = []
    self.layout_configurations.order("order_number ASC").each do |rec|
      if c_block = theme.content_blocks.content_block(rec.predefined_block_name.to_s)
        blocks << c_block
      end
    end
    blocks
  end
end