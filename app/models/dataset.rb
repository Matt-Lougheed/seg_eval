class Dataset < ActiveRecord::Base
    belongs_to :user
    validates :user_id, :name, :description, :image_sequence, :ground_truth, :config_file, presence: true
    validate :proper_image_sequence_format
    validate :proper_config_file_format
    validate :proper_image_size, :if => :image_file_exists?

    # Write an uploaded image sequence to the specified filename
    def write_upload_to_file(uploaded_file, filename)
        FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
        file_path = Rails.root.join(dir_path, filename)
        File.open(file_path, 'wb') do |file|
            file.write(uploaded_file.read)
        end
    end
    
    # Find the dimensions of the image and update the dataset
    def find_image_dimensions
        file_path = Rails.root.join(dir_path, self.image_sequence)
        File.readlines(file_path).each do |line|
            if /DimSize =/ =~ line
                self.width,self.height,self.frames = line.split(" ")[-3..-1]
                break
            end
        end
    end

    # Create frame and thumbnail for .mha file
    def create_frame_and_thumbnail
        if (File.extname(self.image_sequence) == ".mha")
            file_path = Rails.root.join(dir_path, self.image_sequence)
            result = system(Rails.root.join('scripts','mha_to_png','bin',"MhaToPng #{file_path} 1").to_s)
            base_name = File.basename(file_path, ".mha")
            image = MiniMagick::Image.open("#{dir_path}/#{base_name}_frame.png")
            image.resize "200x200"
            image.format "png"
            image.write "#{dir_path}/#{base_name}_thumbnail.png"
            File.chmod(0644, "#{dir_path}/#{base_name}_thumbnail.png")
            self.thumbnail = "#{base_name}_thumbnail.png"
            self.frame = "#{base_name}_frame.png"
        end
    end

    # Create a zip file containing the ground truth and image sequence
    def create_zip
        require 'zip'
        zip_files = [self.ground_truth, self.image_sequence, self.config_file]
        if self.acceptable_segmentation_region.present?
          zip_files.push(self.acceptable_segmentation_region)
        end
        zip_filename = Rails.root.join(dir_path, "#{self.name}.zip")
        Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
            zip_files.each do |file|
                zipfile.add(file, "#{dir_path}/#{file}")
            end
        end
    end
    
    protected
    
    # Custom validation to ensure proper image format
    def proper_image_sequence_format
        if not image_sequence =~ /\.mha\z/
            errors.add(:image_sequence, "must be in .mha format currently")
        end
    end

    def proper_config_file_format
        if not config_file =~ /\.xml\z/
            errors.add(:config_file, "must be in .xml format")
        end
    end
    
    def image_file_exists?
        if image_sequence.nil?
            return false
        else
            test = File.file?(Rails.root.join(dir_path, image_sequence))
            return test
        end
    end

    def proper_image_size
        if ( (File.size(Rails.root.join(dir_path, image_sequence)).to_f / 2**20) > 4.0 )
            errors.add(:image_sequence, "must be smaller than 4 mb")
        end
    end
    
    def dir_path
        Rails.root.join('public', 'uploads', 'dataset', self.user.id.to_s, self.id.to_s)
    end

end
