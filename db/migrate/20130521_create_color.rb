# -*- encoding : utf-8 -*-
class CreateColor < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.string :color_name
      t.string :color_name_ru
      t.timestamps
    end
  end
end