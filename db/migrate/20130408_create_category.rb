# -*- encoding : utf-8 -*-
class CreateCategory < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :gender_id
    	t.integer :departments_id
      t.string :cat_name_en
      t.string :cat_name_ru
      t.string :cat_link
      t.timestamps
    end
    add_index("categories", "gender_id")
    add_index("categories", "departments_id")
  end
end