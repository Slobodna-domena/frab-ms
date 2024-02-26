class ConferenceController < ApplicationController

  before_action :check_admin, except: [:create_account, :update_user]

  PRACTICAL_CONST = ["Non-academic Session"]
  ACADEMIC_CONST = ["Paper Presentation", "Special Session"]

  def create_account
    @user = User.find_by(id: params[:id])
  end

  def mark_paid
    @user = User.find_by(id: params[:id])
    if @user && @user.user_adapter
      @user.user_adapter.update(paid: !@user.user_adapter.paid)
      redirect_to request.referer
    else
      redirect_to request.referer
    end
  end

  def update_user
    user = User.find_by(id: params[:id].to_i)
    if user
      user.update(password: params[:user][:password], gdpr: true)
      sign_in(:user, user)
      redirect_to root_path
      return
    else
      redirect_to root_path
      return
    end
  end


  def show
    conference = Conference.find_by(id: params[:id].to_i)
    if conference
      @papers = Paper.all.select{|paper| paper.event && paper.event.conference_id == conference.id}
      if params[:query]
        @papers = @papers.select{|paper|
          (paper.title && paper.title.downcase.include?(params[:query].downcase)) ||
          (paper.description && paper.description.downcase.include?(params[:query].downcase)) ||
          (paper.subtitle && paper.subtitle.downcase.include?(params[:query].downcase))
        }
      end
      if params[:prikaz]
        if params[:prikaz] == "academic"
          @papers = @papers.select{|paper| paper.event.event_type.in?(ACADEMIC_CONST)}
        elsif params[:prikaz] == "practical"
          @papers = @papers.select{|paper| paper.event.event_type.in?(PRACTICAL_CONST)}
        end
      end
    else
      redirect_to root_path
    end
  end

  def send_email_to
    @user = Person.find(params[:email]).user
    @conference = params[:id]
  end

  def send_email
    conference = Conference.find(params[:id])
    ApplicationMailer.with(email: params[:email], title: params[:title], content: params[:msg]).send_email_to.deliver_later
    redirect_to show_people_path(conference.id)
  end

  def show_people
    @conference = Conference.find_by(id: params[:id].to_i)
    if @conference
      if Payment::PAYMENT_ENABLED
        #@people = @conference.events.map{|e| e.event_people.where(event_role: ["submitter","speaker"]).map{|ep| ep.person}.flatten.uniq}.flatten.uniq.compact
        #@people = @people + User.where("counter is not null").map{|u| u.person}.compact
        #@people = @people + Person.where(id: [777,778])
        #@people = @people.sort_by {|obj| obj.id }
        @people = Person.where("user_id is not null").order(:id)
      else
        @people = @conference.events.map{|e| e.event_people.where(event_role: "submitter").map{|ep| ep.person}.flatten.uniq}.flatten.uniq
      end
      if params[:query]
        @people = @people.select{|p|
          (p.first_name && p.first_name.downcase.include?(params[:query].downcase)) ||
          (p.last_name && p.last_name.downcase.include?(params[:query].downcase)) ||
          (p.email && p.email.downcase.include?(params[:query].downcase))
        }
      end
    else
      redirect_to root_path
    end
  end

  private

  def check_admin
    redirect_to root_path unless current_user && current_user.admin?
  end
end
