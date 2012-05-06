require 'factory_girl'

FactoryGirl.define do
  factory :user do
		name									"Riley Siebel"
		email								  {generate :email}
		password							"foobar"
		password_confirmation	"foobar"
	end
	
	sequence :email do |n|
    "person-#{n}@example.com"
  end
end