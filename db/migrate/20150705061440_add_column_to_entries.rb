class AddColumnToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :hatebu_count, :integer
    add_column :entries, :category, :string
    add_column :entries, :postdate, :datetime
  end
end
