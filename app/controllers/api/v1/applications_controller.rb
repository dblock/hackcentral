module Api
  module V1
    class ApplicationsController < ApplicationController
      protect_from_forgery unless: -> { request.format.json? }
      before_action :doorkeeper_authorize!
      before_action :set_application, only: [:show, :update, :destroy]
      before_action :correct_user, only: [:show, :edit, :update, :destroy]

      def index
        # respond_with @applications = Application.where(user_id: current_user.id).all
        @applications = Application.where(user_id: current_user).all

        respond_to do |format|
          format.json { render :json => @applications } #, :only => [:id, :reimbursement_needed, :accepted] }
        end
      end

      def show
        respond_to do |format|
          format.json { render :json => @application }
        end
      end

      def create
        @application = Application.create!(application_params.merge(user_id: current_user, accepted: nil)) #Application.new(application_params)

        respond_to do |format|
          if @application.save(application_params)
            format.json { render :json => @application, status: :created }
          else
            format.json { render :json => @application.errors, status: :unprocessable_entity }
          end
        end
      end

      def update
        respond_to do |format|
          if @application.update(application_params)
            format.json { render :json => @application, status: :ok }
          else
            format.json { render json: @application.errors, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        @application.destroy

        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private
        def set_application
          @application = Application.find(params[:id])
        end

        def correct_user
          @application = Application.find(params[:id])

          if @application.user_id == current_user
          else
            respond_to do |format|
              format.json { render status: 401 }
            end
          end
        end

        def application_params
          params.require(:application).permit(:reimbursement_needed, :accepted, :user_id, :profile_id, :hackathon_id)
        end
    end
  end
end
