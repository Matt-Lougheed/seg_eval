class RemoveCodeFromAlgorithms < ActiveRecord::Migration
  def change
    remove_column :algorithms, :code, :text
  end
end
