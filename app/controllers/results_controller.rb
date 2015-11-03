class ResultsController < ApplicationController
    before_action :logged_in_user, only: [:new]
    
    def new
        @result = Result.new
        @algorithms = Algorithm.where(user_id: current_user.id)
    end

    def create
        # Find the algorithm which the result was run with
        current_algorithm = Algorithm.find(params[:result][:algorithm_id])

        # Build new result
        @result = current_algorithm.results.build(result_params)

        # Save result and then compute metrics and update
        if @result.save
            # Write the segmentation file to result directory
            uploaded_file = params[:result][:file]
            filename = uploaded_file.original_filename
            dir_path = Rails.root.join('public','uploads','result',current_user.id.to_s,@result.id.to_s)
            FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)
            file_path = Rails.root.join(dir_path,filename)
            File.open(file_path, 'wb') do |file|
                file.write(uploaded_file.read)
            end

            dataset = Dataset.find_by_id(@result.dataset_id)
            results_file_path = dir_path.join('results.txt')
            ground_truth_path = Rails.root.join('public','uploads','dataset',dataset.user_id.to_s,dataset.id.to_s,dataset.ground_truth.to_s).to_s
            
            # Need to create a results file to write the evaluation results to
            system("touch #{results_file_path}")

            # Compute hausdorff distance metric if requested and write it to results file
            if @result.hausdorff == 1
                cmd = Rails.root.join('scripts','hausdorff','bin',"ComputeHausdorff #{file_path} #{ground_truth_path} #{results_file_path}").to_s
                hausdorff_result = system(cmd)
            end

            # Compute dice coefficient metric if requested and write it to results file
            if @result.dice == 1
                cmd = Rails.root.join('scripts','dice_coefficient','bin',"ComputeDiceCoefficient #{file_path} #{ground_truth_path} #{results_file_path}").to_s
                dice_coefficient_result = system(cmd)
            end

            # Update results with the metrics which were run
            results = Hash[*File.read(results_file_path).split(/[\s \n]+/)]

            # Look for the metric computation results and fill in appropriate values
            if results.has_key?("Hausdorff")
                @result.hausdorff = results["Hausdorff"]
            else
                @result.hausdorff = -1
            end
            if results.has_key?("Dice")
                @result.dice = results["Dice"]
            else
                @result.dice = -1
            end
            @result.save

            # Go to new result
            redirect_to @result
        else
            @dataset = Dataset.find_by_id(@result.dataset_id)
            @algorithms = Algorithm.where(user_id: current_user.id)
            render :template => 'datasets/show'
        end
    end

    def show
        @result = Result.find(params[:id])
    end

    def update
        @result = Result.find(params[:id])
        if @result.update_attributes(result_params)
        # Successfully updated the result
            flash[:success] = "Your result has been updated"
            redirect_to @result
        else
            # Unsuccessfull update
            flash[:danger] = "Unable to update the result visibility"
            redirect_to @result
        end
    end

    private

    def result_params
        permitted = params.require(:result).permit(:algorithm_id, :hausdorff, :dice, :dataset_id, :public, :file)
    end
end
