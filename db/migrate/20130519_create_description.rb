# -*- encoding : utf-8 -*-
class CreateDescription < ActiveRecord::Migration
  def change
    create_table :descriptions do |t|
    	t.integer :item_id
      t.float :price
      t.integer :sku
      t.text :description
      t.timestamps
    end
    add_index( "descriptions", "item_id")
  end
end