Feature: Accessing past tasks

  Background:
    Given I am a logged in project owner
    And I am viewing my past tasks

  Scenario: A project owner see tasks they have paid for
    Then I should see all the tasks I have paid out

  Scenario: A project owner see tasks they have rejected
    Then I should see all the tasks I have rejected
