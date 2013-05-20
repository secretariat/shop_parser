# -*- encoding : utf-8 -*-
class CreateImage < ActiveRecord::Migration
  def change
    create_table :images do |t|
    	t.integer :description_id
      t.string :thumb_path
      t.string :image_path
      t.timestamps
    end
    add_index( "images", "description_id")
  end
end