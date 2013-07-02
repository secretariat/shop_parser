# -*- encoding : utf-8 -*-
class CreateWomenCategories < ActiveRecord::Migration
  def change
    create_table :wcategory do |t|
      t.string :cat_name_en
      t.string :cat_name_ru
      t.timestamps
    end
  end
end