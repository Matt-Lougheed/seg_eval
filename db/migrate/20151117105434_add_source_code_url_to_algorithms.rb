class AddSourceCodeUrlToAlgorithms < ActiveRecord::Migration
  def change
    add_column :algorithms, :source_code_url, :string
  end
end
