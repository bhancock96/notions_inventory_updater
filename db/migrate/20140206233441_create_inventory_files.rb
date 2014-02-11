class CreateInventoryFiles < ActiveRecord::Migration
  def change
    create_table :inventory_files do |t|
    	t.string :file
    	t.string :filename
      t.timestamps
    end
  end
end
