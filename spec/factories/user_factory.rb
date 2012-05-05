require 'factory_girl'

FactoryGirl.define do
  factory :user do
		name										"Riley Siebel"
		email									"riley.siebel@example.com"
		password								"foobar"
		password_confirmation	"foobar"
	end
end