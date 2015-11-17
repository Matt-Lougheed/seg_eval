class Algorithm < ActiveRecord::Base
    belongs_to :user
    has_many :results, dependent: :destroy
    validates :name, :description, :programming_language, :source_code_url, presence: true

    def full_url
        /^http/i.match(self.source_code_url) ? self.source_code_url : "http://#{self.source_code_url}"
    end
end
