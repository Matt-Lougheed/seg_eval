class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.references :user, index: true
      t.references :dataset, index: true
      t.references :algorithm, index: true
      t.decimal :hausdorff
      t.decimal :dice

      t.timestamps null: false
    end
    add_foreign_key :results, :users
    add_foreign_key :results, :datasets
    add_foreign_key :results, :algorithms
  end
end
