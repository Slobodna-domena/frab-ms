class ApplicationMailer < ActionMailer::Base
  default from: 'Zagreb Degrowth Conference <zagreb@degrowth.net>'
  layout 'mailer'

  def send_email_to
    @email = params[:email]
    @content = params[:content]
    mail(to: @email, subject: params[:title])
  end

  def send_offer_to
    @user = User.find_by(id: params[:user_id])
    if @user
      #TODO cc
      @amount = 0.0
      if @user.payment.status || @user.payment.country_name.in?(Payment::COUNTRIES)
        @amount = 180.0
      elsif Date.today <= "16-4-2023".to_date
        @amount = 320.0
      elsif Date.today > "16-4-2023".to_date
        @amount = 400.0
      end
      if @user.payment.solidarity_fee
        @amount = @amount + 60.0
      end
      if @user.id == 770
	mail(to: @user.email, subject: "Zagreb Degrowth Conference - Payment Instructions")
      else
      	mail(to: @user.email, subject: "Zagreb Degrowth Conference - Payment Instructions", cc: "info@door.hr")
      end
    end
  end
end
