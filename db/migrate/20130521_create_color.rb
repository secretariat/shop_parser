# -*- encoding : utf-8 -*-
class CreateColor < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      # t.integer :item_id
      t.string :color_name
      t.string :color_name_ru
      t.timestamps
    end
    # add_index("colors", "item_id")
  end
end