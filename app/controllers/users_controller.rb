class UsersController < ApplicationController
    before_action :logged_in_user, only: [:destroy]
    before_action :admin_user, only: :destroy
    
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

    def destroy
        User.find(params[:id]).destroy
        flash[:success] = "User deleted"
        redirect_to users_url
    end

    private

    def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def admin_user
        redirect_to(root_url) unless current_user.admin?
    end

end
