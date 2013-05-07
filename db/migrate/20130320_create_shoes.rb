# -*- encoding : utf-8 -*-
class CreateShoes < ActiveRecord::Migration
  def change
    create_table :shoes do |t|
      t.integer :wcategory_id
      t.string :image_path
      t.string :brandname
      t.string :productname
      t.float :price_usd
      t.float :price_ua
      t.string :discount

      t.timestamps
    end
    add_index("shoes", "wcategory_id")
  end
end