# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :admin?
  before_action :build_user, only: [:create]
  before_action :set_user, only: %i[show edit update destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  # POST /users
  # POST /users.json
  def create
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_admin_path(@user), notice: new_user_message }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_admin_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_admin_index_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def admin?
    unauthorized_response unless current_user&.admin?
  end

  def build_user
    @user = User.new(user_params)
  end

  def new_user_message
    "User was successfully created. Password: #{generated_password}"
  end

  def generated_password
    @generated_password ||= Devise.friendly_token.first(8)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :username).merge!(password: generated_password)
  end

  def unauthorized_response
    render json: {}, status: :unauthorized
  end
end
