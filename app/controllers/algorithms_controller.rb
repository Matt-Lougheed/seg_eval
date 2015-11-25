class AlgorithmsController < ApplicationController
    before_action :logged_in_user, only: [:new, :create]

    def index
        @algorithms = Algorithm.all
    end

    def new
        @algorithm = Algorithm.new
    end

    def create
        @algorithm = current_user.algorithms.build(algorithm_params)
=begin        
        # Validate presence of file
        if algorithm_params[:filename].present?
            @algorithm.filename = algorithm_params[:filename].original_filename.to_s
            @algorithm.filetype = File.extname(@algorithm.filename)
        end

        # Save algorithm, then write the uploaded code to file
        if @algorithm.save
            uploaded_file = algorithm_params[:filename]
            dir = Rails.root.join('public','uploads','algorithm',current_user.id.to_s,@algorithm.id.to_s)
            FileUtils.mkdir_p(dir) unless File.directory?(dir)
            File.open(Rails.root.join('public','uploads','algorithm',current_user.id.to_s,
                                      @algorithm.id.to_s,@algorithm.filename), 'wb') do |file|
                file.write(uploaded_file.read)
            end
            flash[:success] = "Success: new algorithm created!"
            redirect_to @algorithm
=end
        if @algorithm.save
            flash[:success] = "Success: new algorithm created!"
            redirect_to @algorithm
        else
            render 'new'
        end
    end

    def show
        @algorithm = Algorithm.find(params[:id])
        @current_results = Result.where(algorithm_id: @algorithm.id)
    end

    private

    def algorithm_params
        permitted = params.require(:algorithm).permit(:name, :description, :source_code_url, :programming_language)
        return permitted
    end
end
