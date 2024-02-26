class ApplicationController < ActionController::Base

  before_action :authenticate_user!, except: [:login_with_frab, :create_account, :update_user]

  before_action :user_adapter

  def login_with_frab
    if Payment::PAYMENT_ENABLED
      q = params[:q]
      user_id = q.split("e")[0]
      if user_id
        user = User.find_by(id: user_id)
        if user
          if user.last_sign_in_at.nil?
            redirect_to create_account_path(user.id)
            return
          else
            sign_in(:user, user)
            redirect_to root_path
            return
          end
        else
          redirect_to root_path
        end
      else
        redirect_to root_path
      end
    else
      q = params[:q]
      r = params[:r]
      t = params[:t]
      redirect_to root_path if !params.has_key?(:q) || !params.has_key?(:r) || !params.has_key?(:t)
      user_id = q[15..-1].to_i
      user_id_2 = r[20..-1].to_i
      user_id_3 = t[15..-1].to_i
      user = User.find_by(id: user_id)
      if user && (user_id_2 == user_id % 2) && (user_id_3 == user_id % 3)
        sign_in(:user, user)
      end
      redirect_to root_path
    end
  end

  private

  def user_adapter
    if current_user && current_user.user_adapter.nil?
      UserAdapter.create!(user: current_user)
    end
  end


end
