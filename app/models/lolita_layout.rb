class LolitaLayout < ActiveRecord::Base
  include Lolita::Configuration

  has_many :layout_configurations, :class_name => "LolitaLayoutConfiguration", :dependent => :destroy do
    def by_placeholder(placeholder)
      where(:placeholder_name => placeholder.name)
    end
  end
  #has_many :content_blocks, :through => :layout_configurations, :class_name => "LolitaContentBlock"
  has_many :urls, :class_name => "LolitaLayoutUrl", :dependent => :destroy

  validates :name, :theme_name, :title, :presence => true

  accepts_nested_attributes_for :layout_configurations, :allow_destroy => true
  accepts_nested_attributes_for :urls, :allow_destroy => true

  lolita do
    tab(:default) do
      field :title
      nested_fields_for(:urls, :build_method => :ordered_urls) do
        field :path, :string
        field :path_select, :array, :builder => {:name => "/lolita/template_engine/layout", :state => "urls"}
      end
      field :theme_name, :hidden
      field :name, :hidden
    end
  end

  def ordered_urls
    self.urls.order("lolita_layout_urls.id asc")
  end

  def self.recognize_from(theme,request)
    layouts_by_theme = self.by_theme(theme)
    if url = LolitaLayoutUrl.recognize(layouts_by_theme,request)
      url.lolita_layout
    end
  end

  def self.by_theme(theme)
    where(:theme_name => theme.name)
  end

  def theme
    Lolita.themes.theme(self.theme_name.to_s)
  end

  def layout
    self.theme && self.theme.layouts.layout(self.name.to_s)
  end

  def content_blocks_for_placeholder(placeholder)
    blocks = []
    current_theme = self.theme
    self.layout_configurations.where(:placeholder_name => placeholder.name).order("order_number ASC").map do |l_config|
      l_config.content_block(current_theme)
    end.compact
  end
end