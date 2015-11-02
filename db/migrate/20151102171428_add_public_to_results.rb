class AddPublicToResults < ActiveRecord::Migration
  def change
    add_column :results, :public, :integer
  end
end
