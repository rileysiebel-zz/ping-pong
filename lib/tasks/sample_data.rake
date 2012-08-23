require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    Match.skip_callback(:after_save)
    Rake::Task['db:reset'].invoke
    admin = User.create!({name:                  "Example User",       
                          email:                 "example@pingpong.org",
                          password:              "foobar",
                          password_confirmation: "foobar"})
    admin.toggle!(:admin)                        
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@pingpong.org"
      password = "password"
      User.create!({name: name, email: email, 
                    password: password, password_confirmation: password})
    end
    User.all(limit: 6).each do |user|
      #TODO fix random
      25.times do
        c_score, d_score = Match.generate_valid_score
        challenger = User.random
        user.defender_matches.create!({ challenger: challenger, 
          defender_score: d_score, challenger_score: c_score })
      end
      25.times do
        c_score, d_score = Match.generate_valid_score
        defender = User.random
        user.challenger_matches.create!({ defender: defender, 
          defender_score: d_score, challenger_score: c_score })
      end
    end
    #Match.set_callback(:after_save)
  end
end
