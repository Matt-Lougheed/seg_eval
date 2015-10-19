class DatasetsController < ApplicationController
    before_action :logged_in_user, only: [:new, :create]
    def index
        @datasets = Dataset.all
    end

    def new
        @dataset = Dataset.new
    end

    def create
        @dataset = current_user.datasets.build(dataset_params)
        @dataset.download_num = 0
        if @dataset.save
            # Write the dataset to file
            uploaded_file = params[:dataset][:file]
            filename = uploaded_file.original_filename
            dir_path = Rails.root.join('public/uploads/dataset',current_user.id.to_s,@dataset.id.to_s)
            FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
            file_path = Rails.root.join(dir_path,filename)
            File.open(file_path, 'wb') do |file|
                file.write(uploaded_file.read)
            end

            # Write the ground truth to file
            ground_truth_file = params[:dataset][:ground_truth]
            filename = ground_truth_file.original_filename
            ground_truth_path = Rails.root.join(dir_path,filename)
            File.open(ground_truth_path, 'wb') do |file|
                file.write(uploaded_file.read)
            end

            # Create frame and thumbnail for .mha file
            if (File.extname(file_path) == ".mha")
              #system("/data/code/itk_scripts/mha_to_png/bin/MhaToPng #{file_path} 1")
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
            require 'zip'
            zip_files = [ground_truth_file.original_filename, uploaded_file.original_filename]
            zip_filename = Rails.root.join(dir_path, "Dataset_#{@dataset.id}.zip")

            Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
                zip_files.each do |file|
                    zipfile.add(file, "#{dir_path}/#{file}")
                end
            end

            @dataset.save
            flash[:sucess] = "Success: new dataset created!"
            redirect_to @dataset
        else
            render 'new'
        end
    end

    def download
        puts "in download"
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
    end

    private

    # TODO: will need to remove filename and thumbnail as these will be generated from uploaded files
    def dataset_params
        permitted = params.require(:dataset).permit(:name,:description,:height,:width,:frames)
        permitted[:filename] = params[:dataset][:file].original_filename
        permitted[:ground_truth] = params[:dataset][:ground_truth].original_filename
        return permitted
    end
end
