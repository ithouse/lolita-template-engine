class LolitaContentBlock < ActiveRecord::Base
  include Lolita::Configuration
  has_many :layout_configurations, :class_name => "LolitaLayoutConfiguration", :dependent => :destroy
 # has_many :layouts, :through => :layout_configurations, :class_name => "LolitaLayout"
  after_save :clean_configuration
  validates :width,:height,:name,:body, :presence => true

  lolita do
    list do
      column :name
      column :width
      column :height
      column :theme_name
      column :placeholder_name
    end

    tab(:content) do
      field :name
      field :body, :string,:builder => :text, :simple => true
      field :width, :integer do
        title "#{LolitaContentBlock.human_attribute_name("width")} (#{self.dbi.klass.placeholders.map(&:width).sort.uniq.join(", ")})"
      end
      field :height, :integer, do 
        title "#{LolitaContentBlock.human_attribute_name("height")} (#{self.dbi.klass.placeholders.map(&:height).sort.uniq.join(", ")})"
      end
      field :theme_name, :array do
        include_blank "-Theme-"
        options_for_select(Lolita.themes.names.sort.map{|n| [n.humanize,n]})
      end

      field :placeholder_name, :array do
        include_blank "-Placeholder-"
        options_for_select(self.dbi.klass.placeholder_names.uniq.map{|n| [n.humanize,n]}.sort)
      end
    end
  end

  class << self

    def placeholders
      all_placeholder_names = Lolita.themes.map{|n,theme| 
        theme.layouts.map{|ln,layout| 
          layout.placeholders.map{|n,ph| ph}
        }
      }.flatten
    end

    def placeholder_names
      self.placeholders.map(&:name)
    end

    def all_with(theme)
      blocks = self.arel_table
      self.where(without_theme(blocks).or(with_theme(blocks,theme)))
    end

    def with_theme(blocks,theme)
      blocks[:theme_name].eq(theme && theme.name)
    end

    def without_theme blocks
      blocks[:theme_name].eq("").or(blocks[:theme_name].eq(nil))
    end
  end

  def parsed_options
    result = parse_options
    result[0] && result[0]="single"
  end

  private

  def clean_configuration
    self.layout_configurations.each do |lc|
      if theme = Lolita.themes.theme(lc.lolita_layout && lc.lolita_layout.theme_name)
        if self.theme_name.present? && self.theme_name!=theme.name
          lc.destroy
          next
        end
        placeholder = nil
        theme.layouts.each{|n,layout| 
          layout.placeholders.each{|n,p_holder| 
            placeholder = p_holder if p_holder.name == lc.placeholder_name
          }
        } 
        if placeholder
          if (self.width > placeholder.width && placeholder.stretch.to_s!="horizontally") ||
            (self.height > placeholder.width && placeholder.stretch.to_s!="vertically") ||
            self.placeholder_name.present? && placeholder.name!=self.name
            lc.destroy
          end
        end
      end
    end
  end

  def parse_options
    opt_nr = self.options
    result = []
    4.downto(1) do |i|
      if opt_nr - 2**i >=0
        result << true
        opt_nr -= 2**i
      else
        result << false
      end
    end
  end
end