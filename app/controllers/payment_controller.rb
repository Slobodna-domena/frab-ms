class PaymentController < ApplicationController

  #before_action :check_if_review_done

  def index
    if current_user.payment.nil?
      @item = Payment.create(user_id: current_user.id)
    else
      @item = current_user.payment
    end
  end

  def update
    payment = Payment.find(params[:id])
    if payment.update(payment_params)
      if params[:payment][:country].blank?
  	    redirect_to payment_path(error: "You need to choose your country.")
  	    return
      else
         payment.update(request_date: DateTime.now)
         ApplicationMailer.with(user_id: current_user.id).send_offer_to.deliver_later
         redirect_to payment_path
	       return
      end
    else
      redirect_to payment_path(image_error: "Image format needs to be jpg, png or jpeg.")
    end
  end

  private

  def payment_params
   params.require(:payment).permit(:country,:solidarity_fee, :document, :status, :billing_name, :billing_address, :billing_vat)
 end

  def check_if_review_done
    if Payment::PAYMENT_ENABLED
      redirect_to root_path
    end
  end
end
