class AddAcceptableSegmentationRegionToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :acceptable_segmentation_region, :string
  end
end
