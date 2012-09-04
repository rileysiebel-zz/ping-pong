Feature: Allow new users to sign up
  Background:
    Given I go to the home page

  Scenario: Show the home page elements
    Then I should see a Sign up now! button
    Then I should see a Sign in button

  Scenario: Signup
    When I click Sign up now!
    Then I should be on the Sign up page