class Result < ActiveRecord::Base
    belongs_to :algorithm
    belongs_to :dataset
    has_one :user, :through => :algorithm
    validates_presence_of :dataset_id, :algorithm_id
    validate :at_least_one_evaluation_method
    validate :presence_of_segmentation_file, :on => :create

    attr_accessor :file
    
    def at_least_one_evaluation_method
        if hausdorff == 0 and dice == 0
            errors.add(:base, "At least one validation method must be selected")
        end
    end

    def presence_of_segmentation_file
        unless file.present?
            errors.add(:file, "Must supply a segmentation file")
        end
    end
    
end
