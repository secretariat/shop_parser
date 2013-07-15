# -*- encoding : utf-8 -*-
class CreateBrand < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :title, :default => "", :null => false
      t.string :meta_d, :default => "", :null => false
      t.string :meta_k, :default => "", :null => false
      t.string :logo, :default => "", :null => false
      t.text :text, :default => "", :null => false
      t.string :name
      t.string :name_shown
      t.boolean :active, :default => true
      t.timestamps
    end
  end
end