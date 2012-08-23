Then /^I should see a (.+) button$/ do |button|
  page.should have_link button
end
When /^I click (.+)/ do |button|
  page.click_link_or_button button
end