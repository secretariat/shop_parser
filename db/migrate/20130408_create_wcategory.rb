# -*- encoding : utf-8 -*-
class CreateWcategory < ActiveRecord::Migration
  def change
    create_table :wcategories do |t|
      t.string :cat_name_en
      t.string :cat_name_ru
      t.string :cat_link
      t.timestamps
    end
  end
end