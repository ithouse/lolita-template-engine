class CreateLolitaLayoutUrl < ActiveRecord::Migration
  def change
    create_table :lolita_layout_urls, :force => true do |t|
      t.string :path
      t.integer :lolita_layout_id
    end

    add_index :lolita_layout_urls, :path, :name => "lolita_lu_path"
    add_index :lolita_layout_urls, :lolita_layout_id, :name => "lolita_lu_layout"
  end
end