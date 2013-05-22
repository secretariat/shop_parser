# -*- encoding : utf-8 -*-
class CreateItem < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :category_id
      t.integer :product_id
      t.integer :color_id
      t.integer :style_id
      t.integer :brand_id
      t.string :image_path
      t.string :productname
      t.float :price_usd
      t.float :price_ua
      t.string :discount

      t.timestamps
    end
    add_index("items", "category_id")
    add_index("items", "brand_id")
    add_index("items", "color_id")
  end
end