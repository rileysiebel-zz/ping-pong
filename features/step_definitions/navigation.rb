When /^I go to the home page$/ do
  visit root_path
end
Then /^I should be on the (.+?) page$/ do |page_name|
  page.find(:css, 'title').text.should == title_for(page_name)
end

def current_path
  URI.parse(current_url).path
end

def title_for(title)
  "Investor | #{title}"
end