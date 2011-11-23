class LolitaLayoutConfiguration < ActiveRecord::Base
  belongs_to :lolita_layout, :class_name => "LolitaLayout"
  belongs_to :lolita_content_block, :class_name => "LolitaContentBlock"

  def content_block(theme = nil)
    if self.lolita_content_block
      self.lolita_content_block
    else
      theme ||= self.lolita_layout.theme
      if theme
        theme.content_blocks.content_block(self.predefined_block_name.to_s)
      end
    end
  end

end