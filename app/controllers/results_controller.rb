class ResultsController < ApplicationController
    before_action :logged_in_user, only: [:new]
    
    def new
        @result = Result.new
        @algorithms = Algorithm.where(user_id: current_user.id)
        puts @algorithms
    end

    def create
        puts params
        current_algorithm = Algorithm.find(params[:result][:algorithm_id])
        @result = current_algorithm.results.build(result_params)
        if @result.save
            # Write the segmentation file to result directory
            uploaded_file = params[:result][:file]
            filename = uploaded_file.original_filename
            dir_path = Rails.root.join('public/uploads/result/',current_user.id.to_s,@result.id.to_s)
            puts "***************" + dir_path.to_s
            FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
            file_path = Rails.root.join(dir_path,filename)
            File.open(file_path, 'wb') do |file|
                file.write(uploaded_file.read)
            end

            dataset = Dataset.find_by_id(@result.dataset_id)
            puts "********** RUNNING ComputeHausdorff **************"
            cmd = Rails.root.join("scripts/hausdorff/bin/ComputeHausdorff #{file_path} public/uploads/dataset/#{dataset.user_id}/#{dataset.id}/#{dataset.filename}").to_s
            puts cmd
            hausdorff_result = system(cmd)
            puts "*********** #{hausdorff_result.to_s} **************"
            redirect_to @result
        else
            render 'new'
        end
    end

    def show
        @result = Result.find(params[:id])
    end

    private

    def result_params
        permitted = params.require(:result).permit(:algorithm_id, :hausdorff, :dice, :dataset_id)
    end
end
