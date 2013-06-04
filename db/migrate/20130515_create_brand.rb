# -*- encoding : utf-8 -*-
class CreateBrand < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :brand_name
      t.string :brand_name_shown
      t.boolean :active, :default => true
      t.timestamps
    end
  end
end