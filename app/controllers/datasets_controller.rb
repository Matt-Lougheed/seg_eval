class DatasetsController < ApplicationController
    before_action :logged_in_user, only: [:new, :create]
    def index
        @datasets = Dataset.all
    end

    def new
        @dataset = Dataset.new
    end

    def create
        # Build new dataset
        @dataset = current_user.datasets.build(dataset_params)

        # Set starting downloads to zero
        @dataset.download_num = 0
        
        # Validate presence of original and ground truth images from form and sets the filenames
        if dataset_params[:image_sequence].present?
            @dataset.image_sequence = dataset_params[:image_sequence].original_filename.to_s
        end
        if dataset_params[:ground_truth].present?
            @dataset.ground_truth = dataset_params[:ground_truth].original_filename.to_s
        end

        # Save the dataset, then we must write the files
        if @dataset.save
            # Write the dataset to file
            uploaded_file = dataset_params[:image_sequence]
            dir_path = Rails.root.join('public','uploads','dataset',current_user.id.to_s,@dataset.id.to_s)
            FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
            file_path = Rails.root.join(dir_path, @dataset.image_sequence)
            File.open(file_path, 'wb') do |file|
                file.write(uploaded_file.read)
            end

            # Write the ground truth to file
            ground_truth_file = dataset_params[:ground_truth]
            ground_truth_path = Rails.root.join(dir_path, @dataset.ground_truth)
            File.open(ground_truth_path, 'wb') do |file|
                file.write(ground_truth_file.read)
            end

            # Create frame and thumbnail for .mha file
            if (File.extname(file_path) == ".mha")
                result = system(Rails.root.join('scripts','mha_to_png','bin',"MhaToPng #{file_path} 1").to_s)
                base_name = File.basename(file_path, ".mha")
                image = MiniMagick::Image.open("#{dir_path}/#{base_name}_frame.png")
                image.resize "200x200"
                image.format "png"
                image.write "#{dir_path}/#{base_name}_thumbnail.png"
                File.chmod(0644,"#{dir_path}/#{base_name}_thumbnail.png")
                @dataset.thumbnail = "#{base_name}_thumbnail.png"
                @dataset.frame = "#{base_name}_frame.png"                
            end

            # Zip the files together as a package for users to download
            require 'zip'
            zip_files = [ground_truth_file.original_filename, uploaded_file.original_filename]
            zip_filename = Rails.root.join(dir_path, "Dataset_#{@dataset.id}.zip")
            Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
                zip_files.each do |file|
                    zipfile.add(file, "#{dir_path}/#{file}")
                end
            end

            # Update the dataset with the new paths for thumbnail and frame
            @dataset.save
            flash[:success] = "Success: new dataset created!"
            redirect_to @dataset
        else
            render :new
        end
    end

    def download
        dataset = Dataset.find(params[:dataset_id])
        send_file "#{Rails.root}/public/uploads/dataset/#{dataset.user_id}/#{dataset.id}/Dataset_#{dataset.id}.zip"
        Dataset.increment_counter(:download_num, dataset.id)
        dataset.save!
    end

    def destroy
    end

    def show
        @dataset = Dataset.find(params[:id])
        if logged_in?
            @algorithms = Algorithm.where(user_id: current_user.id)
        end
        @result = Result.new
        @current_results = Result.where(dataset_id: @dataset.id)
    end

    private

    def dataset_params
        permitted = params.require(:dataset).permit(:name,:description,:height,:width,:frames,:image_sequence,:ground_truth)
        return permitted
    end
end
