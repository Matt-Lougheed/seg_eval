class Dataset < ActiveRecord::Base
    belongs_to :user
    validates :user_id, :name, :description, :image_sequence, :ground_truth, presence: true
    validate :proper_image_sequence_format
    
    # Custom validations
    def proper_image_sequence_format
        if not image_sequence =~ /\.mha\z/
            errors.add(:image_sequence, "must be in .mha format currently")
        end
    end
    
end
