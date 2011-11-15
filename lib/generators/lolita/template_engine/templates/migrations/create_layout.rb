class CreateLolitaLayout < ActiveRecord::Migration
  def change
    create_table :lolita_layouts, :force => true do |t|
      t.string  :name
      t.string  :theme_name
    end
  end
end
