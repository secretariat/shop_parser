# -*- encoding : utf-8 -*-
class CreateColorsItemsJoin < ActiveRecord::Migration
  def change
    create_table :colors_items, :id => false do |t|
      t.integer "item_id"
      t.integer "color_id"
    end
    add_index :colors_items, ["item_id", "color_id"]
  end
end