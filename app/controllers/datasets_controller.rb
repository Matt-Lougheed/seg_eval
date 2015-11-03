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

        # Save the dataset, then we must write the files and update the dataset
        if @dataset.save
            # Write the dataset to file
            @dataset.write_sequence_to_file(dataset_params[:image_sequence], @dataset.image_sequence)

            # Write the ground truth to file
            @dataset.write_sequence_to_file(dataset_params[:ground_truth], @dataset.ground_truth)

            # Find the dimensions for the sequence
            @dataset.find_image_dimensions
            
            # Create frame and thumbnail for .mha file
            @dataset.create_frame_and_thumbnail

            # Zip the files together as a package for users to download
            @dataset.create_zip

            # Update the dataset with the new paths for thumbnail and frame
            @dataset.save

            # Redirect to newly created dataset and display success notification
            flash[:success] = "Success: new dataset created!"
            redirect_to @dataset
        else
            render :new
        end
    end

    def download
        dataset = Dataset.find(params[:dataset_id])
        send_file "#{Rails.root}/public/uploads/dataset/#{dataset.user_id}/#{dataset.id}/#{dataset.name}.zip"
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
        permitted = params.require(:dataset).permit(:name, :description, :image_sequence, :ground_truth)
        return permitted
    end
end
