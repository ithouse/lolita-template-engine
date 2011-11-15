class LolitaLayoutConfiguration < ActiveRecord::Base
  belongs_to :layout, :class_name => "LolitaLayout"
  belongs_to :content_block, :class_name => "LolitaContentBlock"
end