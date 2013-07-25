# -*- encoding : utf-8 -*-
class CreateWidth < ActiveRecord::Migration
  def change
    create_table :widths do |t|
      t.string :name_us
      t.string :name_ru
      t.timestamps
    end
  end
end