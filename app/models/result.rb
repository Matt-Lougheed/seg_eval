class Result < ActiveRecord::Base
    belongs_to :algorithm
    belongs_to :dataset
    has_one :user, :through => :algorithm
end
