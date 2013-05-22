# -*- encoding : utf-8 -*-
class CreateSize < ActiveRecord::Migration
  def change
    create_table :sizes do |t|
    	t.integer :item_id
      t.string :size_value
      t.string :size_value_ru
      t.timestamps
    end
    add_index("sizes", "item_id")
  end
end