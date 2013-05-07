# -*- encoding : utf-8 -*-
class CreateCategory < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :cat_name_en
      t.string :cat_name_ru
      t.string :cat_link
      t.timestamps
    end
  end
end