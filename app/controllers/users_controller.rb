class UsersController < ApplicationController

    def index
        @users = User.all
    end
    
    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.save
            log_in @user
            flash[:success] = "Welcome to TODO: Name of App!"
            redirect_to @user
        else
            render 'new'
        end
    end
    
    def show
        @user = User.find(params[:id])
        @datasets = @user.datasets
        @algorithms = @user.algorithms
        # Must be a better way for this...
        @results = []
        @algorithms.each do |a|
            a.results.each do |r|
                @results << r
            end
        end
    end

    private

    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
