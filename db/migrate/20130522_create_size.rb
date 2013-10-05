# -*- encoding : utf-8 -*-
class CreateSize < ActiveRecord::Migration
  def change
    create_table :sizes do |t|
    	# t.integer :item_id
      t.string :name_us
      t.string :name_ru
      t.timestamps
    end
    # add_index("sizes", "item_id")
  end
end