class CreateEntries < ActiveRecord::Migration
  def change 
    add_column :entries, :slide_base_image_url, :string
    add_column :entries, :sitename, :string
    add_column :entries, :total_count, :integer
  end

end
