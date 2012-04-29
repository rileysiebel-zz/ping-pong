module ApplicationHelper

  # Return the correct title for a particular page
  def title
    base_title = "Investor"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
end
