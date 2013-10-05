# -*- encoding : utf-8 -*-
class CreateDepartment < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name_us
      t.string :name_ru
      t.string :link
      t.boolean :active
      t.timestamps
    end
  end
end