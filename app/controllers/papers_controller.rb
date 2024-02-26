class PapersController < ApplicationController

  #before_action :check_user_role, except: :index

  before_action :check_if_review_done

  def index
    if current_user
      @user_conferences = current_user.conferences#.select{|conference| conference.cfp_ended}
      @related = current_user.get_related_papers
      @related = @related.blank? ? Hash.new : @related
      @crew = current_user && current_user.role != "submitter"
      @admin = current_user && current_user.admin?
    end
  end

  def show
    @item = Paper.find(params[:id])
    @event_rating = EventRating.find_by(person_id: current_user.person.id, event: @item.event, peer: true)
  end

  def accept
    paper = Paper.find(params[:id])
    if paper && current_user.can_accept?(paper.event.conference_id) && !current_user.user_adapter.accepted.include?(paper.id)
      user_adapter = current_user.user_adapter
      user_adapter.accepted << paper.id
      user_adapter.save!
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def remove_rating
    if current_user && current_user.admin?
      event_rating = EventRating.find_by(id: params[:id].to_i, peer: true)
      if event_rating
        event_rating.destroy!
        redirect_to paper_path(Paper.find_by(event_id: event_rating.event.id))
      else
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  def rate
    paper = Paper.find(params[:id])
    if paper && !current_user.graded?(paper) && EventRating.where(event: paper.event, person: current_user.person, peer: true).blank?
      conf = paper.event.conference
      total_rating = 0.0
      count = 0
      conf.review_metrics.each do |metric|
        if params[metric.name.to_sym]
          total_rating = total_rating + (params[metric.name.to_sym].to_i/2.0).round(1)
          count = count + 1
        end
      end
      EventRating.create(event: paper.event,peer: true, rating: (total_rating/(count*1.0)).round(1), comment: params[:note],person: current_user.person)
      user_adapter = current_user.user_adapter
      user_adapter.papers_evaluated << paper.id
      if !user_adapter.accepted.include?(paper.id)
        user_adapter.accepted << paper.id
      end
      user_adapter.save!
      redirect_to paper_path(paper)
    else
      redirect_to root_path
    end
  end

  def grade
    @item = Paper.find_by(id: params[:id])
    if @item.nil?
      redirect_to root_path
    end
    @conference = @item.event.conference
  end

  def skip
    paper = Paper.find(params[:id])
    if paper
      adapter = current_user.user_adapter
      if !current_user.skipped?(paper.id)
        adapter.skipped << paper.id
        adapter.save!
      end
      redirect_to root_path
    end
  end

  private

  def check_user_role
    if current_user && current_user.role != "submitter"
      redirect_to root_path
    end
  end

  def check_if_review_done
    if Payment::PAYMENT_ENABLED && current_user && !current_user.admin?
      redirect_to payment_path
    end
  end
end
