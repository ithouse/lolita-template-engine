class CreateLolitaLayout < ActiveRecord::Migration
  def change
    create_table :lolita_layouts, :force => true do |t|
      t.string  :title, :limit => 30
      t.string  :name, :limit => 30
      t.string  :theme_name, :limit => 30
    end
  end
end
