module ApplicationHelper

  def full_title(title="")
    base_title = "Ruby on Rails Tutorial Sample App"
    if title.empty?
      return base_title
    else
      return "#{title} | #{base_title}"
    end
  end
end
