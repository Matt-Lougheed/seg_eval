class AddFrameToDataset < ActiveRecord::Migration
  def change
    add_column :datasets, :frame, :string
  end
end
