class AddDescription < ActiveRecord::Migration
  def self.up
    add_column :banners, :description, :text
  end

  def self.down
    remove_column :banners, :description
  end
end
