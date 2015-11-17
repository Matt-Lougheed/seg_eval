class Algorithm < ActiveRecord::Base
    belongs_to :user
    has_many :results, dependent: :destroy
    validates :name, :description, :source_code_url, presence: true
end
