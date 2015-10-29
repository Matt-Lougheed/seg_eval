class FixDatasetsColumnNames < ActiveRecord::Migration
    def change
        change_table :datasets do |t|
            t.rename :filename, :image_sequence
        end
    end
end
