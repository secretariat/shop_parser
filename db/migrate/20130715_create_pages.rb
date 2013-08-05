# -*- encoding : utf-8 -*-
class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name, :default=>"", :null=>false
      t.string :title, :default=>"", :null=>false
      t.string :meta_d, :default=>"", :null=>false
      t.string :meta_k, :default=>"", :null=>false
      t.string :uri, :default=>"", :null=>false
      t.text :text
      t.boolean :active, :null=>false, :default=>false
      t.timestamps
    end
  end
end