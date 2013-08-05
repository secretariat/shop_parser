# -*- encoding : utf-8 -*-
class CreateDepartment < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :dep_name_en
      t.string :dep_name_ru
      t.string :dep_link
      t.boolean :active
      t.timestamps
    end
  end
end