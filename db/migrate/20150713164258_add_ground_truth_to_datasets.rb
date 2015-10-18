class AddGroundTruthToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :ground_truth, :string
  end
end
