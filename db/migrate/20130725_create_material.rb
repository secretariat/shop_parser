# -*- encoding : utf-8 -*-
class CreateMaterial < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :name_us
      t.string :name_ru
      t.string :link
      t.timestamps
    end
  end
end