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
  
  factory :user_with_matches, parent: :user do
    after_create do |user|
      FactoryGirl.create(:match, defender: user, challenger: FactoryGirl.create(:user))
    end
  end
  
  factory :match do
    defender_score      18
    challenger_score    21
    association :defender, factory: :user
    association :challenger, factory: :user
  end
end