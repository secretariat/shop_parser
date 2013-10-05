# -*- encoding : utf-8 -*-
class CreateSubdepartment < ActiveRecord::Migration
  def change
    create_table :subdepartments do |t|
      t.integer :department_id
    	t.integer :gender_id
      t.string :name_us
      t.string :name_ru
      t.string :cat_link
      t.timestamps
    end
    add_index("subdepartments", "department_id")
    add_index("subdepartments", "gender_id")
  end
end