class CreateLolitaContentBlock < ActiveRecord::Migration
  def change
    create_table :lolita_content_blocks, :force => true do |t|
      t.string :name, :limit => 40
      t.text :body
      t.string  :theme_name, :limit => 30
      t.string  :placeholder_name, :limit => 30
    end

    add_index :lolita_content_blocks, :theme_name, :name => "lolita_cb_theme"
    add_index :lolita_content_blocks, :placeholder_name, :name => "lolita_cb_ph"
  end
end