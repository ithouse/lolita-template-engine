class CreateLolitaLayoutConfiguration < ActiveRecord::Migration
  def change
    create_table :lolita_layout_configurations, :force => true do |t|
      t.integer :layout_id
      t.string  :placeholder_name, :limit => 30
      t.integer :content_block_id
      t.string  :predefined_block_name
      t.integer :order_number
      t.integer :options
    end

    add_index :lolita_layout_configurations, [:layout_id, :order_number], :name => "lolita_lc_complex"
    add_index :lolita_layout_configurations, :content_block_id, :name => "lolita_lc_cb"
    add_index :lolita_layout_configurations, :order_number, :name => "lolita_lc_on"
    add_index :lolita_layout_configurations, :layout_id, :name => "lolita_lc_layout"
  end
end