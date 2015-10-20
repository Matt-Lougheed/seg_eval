class Dataset < ActiveRecord::Base
    belongs_to :user
    validates :user_id, presence: true
    validates :name, presence: true
    validates :description, presence: true

    attr_accessor :image_file
    attr_accessor :ground_truth_file

    validates :image_file, presence: true
    validates :ground_truth_file, presence: true
end
