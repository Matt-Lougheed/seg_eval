class AddConfigFileToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :config_file, :string
  end
end
