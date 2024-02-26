class Paper < ApplicationRecord
  belongs_to :event
  has_many :grades

  SUPPORTED = %w[en de es pt-BR fr zh ru it].freeze

  PRACTICAL_CONST = ["Non-academic Session"]
  ACADEMIC_CONST = ["Paper Presentation", "Special Session"]

  def as_json(options={})
    #options[:methods] = [:is_password]
    #options[:include] = [:event => {:include => {:event_classifiers}}]
    super(:include => [:grades,:event => {:include => [:event_classifiers]}], :methods => [:average_grade])
  end

  def check_paper(conf,user)
    self.event &&
    self.event.conference_id == conf.id &&
    !user.skipped?(self.id) &&
    ((self.event.event_type.in?(ACADEMIC_CONST) && !self.finished_with_accepted?) || (self.event.event_type.in?(PRACTICAL_CONST) && !self.finished_with_accepted?))
  end

  def user_not_coauthor?(user)
    return true if user.email.blank?
    return false if self.event.nil?
    event = self.event
    return false if event.coauthor_1 == user.email || event.coauthor_2 == user.email || event.coauthor_3 == user.email || event.coauthor_4 == user.email || event.coauthor_5 == user.email
    return true
  end

  def average_grade
    avg = 0
    self.grades.each{|g| avg = avg + g.value}
    return avg*1.0/self.grades.size
  end

  def title
    self.event.title if self.event
  end

  def finished_with_accepted?
    return true if self.event.event_ratings.where(peer: true).size >= 3
    total = self.event.event_ratings.where(peer: true).size
    return UserAdapter.all.select{|ua| ua.accepted.include?(self.id)}.size >= 3
  end

  def subtitle
    self.event.subtitle if self.event
  end

  def description
    self.event.description if self.event
  end

  def abstract
    self.event.abstract if self.event
  end


  def finished?
    return false if self.event.nil?
    return self.event.event_ratings.where(peer: true).size >= 3
  end

  def language
    case self.event.language
    when "en"
      "English"
    when "de"
      "German"
    when "es"
      "Spanish"
    when "fr"
      "French"
    when "ru"
      "Russian"
    when "it"
      "Italian"
    when "pt-BR"
      "Portuguese"
    when "zh"
      "Chinese"
    else
      "Not defined"
    end if self.event
  end

  def documents
    self.event.event_attachments.select{|ea| ea.public} if self.event
  end

  def links
    self.event.links if self.event
  end

  def classifiers
    self.event.event_classifiers.map{|ec| ec.classifier}.uniq if self.event
  end

  def event_type
    self.event.event_type if self.event
  end

end
