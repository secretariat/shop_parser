# -*- encoding : utf-8 -*-
class CreateShoes < ActiveRecord::Migration
  def change
    create_table :shoes do |t|
      t.string :image
      t.string :brandname
      t.string :productname
      t.string :price
      t.string :discount

      t.timestamps
    end
  end
end