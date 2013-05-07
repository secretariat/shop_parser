# -*- encoding : utf-8 -*-
class CreateSubdepartment < ActiveRecord::Migration
  def change
    create_table :subdepartments do |t|
    	t.integer :department_id
      t.string :subdep_name_en
      t.string :subdep_name_ru
      t.string :cat_link
      t.timestamps
    end
    add_index("subdepartments", "department_id")
  end
end