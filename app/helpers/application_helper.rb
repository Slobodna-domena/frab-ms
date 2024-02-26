module ApplicationHelper

  def description_for(metric)
    case metric
    when 1
      return "Please assess on a sliding scale (bad-good) how relevant the proposal is to the conference theme (1-12) under which it is submitted."
    when 3
      return "Is the abstract well structured? Is the argument clear? Please rate on a scale below."
    when 4
      return "Are the methods or the approach innovative for the degrowth discussions? Do they promise new relevant results? Does this abstract show something of novelty? Please rate on scale below."
    when 2
      return "Please asses the relevance of the presentation in relation to the issues you would expect the International Degrowth Conference to address."
    else
      return ""
    end
  end
end
