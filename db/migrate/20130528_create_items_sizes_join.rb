# -*- encoding : utf-8 -*-
class CreateItemsSizesJoin < ActiveRecord::Migration
  def change
    create_table :items_sizes, :id => false do |t|
      t.integer "item_id"
      t.integer "size_id"
    end
    add_index :items_sizes, ["item_id", "size_id"]
  end
end