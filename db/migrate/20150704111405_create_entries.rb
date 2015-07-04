class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.string :title
      t.string :link
      t.string :description
    end
  end

  def self.down
    drop_table :entries
  end
end
