require 'faker'

def generate_valid_score
  w_score = 21 + rand(21)
  if w_score.equal?(21)
    l_score = 1 + rand(20)
  else
    l_score = 20 + rand(w_score - 21)
  end

  # assign scores randomly
  if rand(2) == 1
    c_score = w_score
    d_score = l_score
  else
    c_score = l_score
    d_score = w_score
  end
  return c_score, d_score
end

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
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
      25.times do
        c_score, d_score = generate_valid_score()
        challenger = User.random
        user.defender_matches.create!({ challenger: challenger, 
          defender_score: d_score, challenger_score: c_score })
      end
      25.times do
        # generate valid score
        c_score, d_score = generate_valid_score()

        defender = User.random
        user.challenger_matches.create!({ defender: defender, 
          defender_score: d_score, challenger_score: c_score })
      end
    end
  end
end
