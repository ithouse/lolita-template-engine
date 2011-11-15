class LolitaLayoutUrl < ActiveRecord::Base
  belongs_to :layout, :class_name => "LolitaLayout"
end