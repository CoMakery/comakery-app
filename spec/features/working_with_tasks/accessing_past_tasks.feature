Feature: Accessing past tasks
  …

  Background:
    Given I am a logged in user
    And I want to view past tasks

  Scenario: A project owner wants to view tasks they have paid for
    When I visit the ‘Done’ filter
    Then I should see all the tasks I have paid out

  Scenario: A project owner wants to view tasks they have rejected
    When I visit the ‘Done’ filter
    Then I should see all the tasks I have rejected

  Scenario: A contributor wants to view tasks they been paid for
    When I visit the ‘Done’ filter
    Then I should see all the tasks I have been paid for

  Scenario: A contributor wants to view tasks that have been rejected
    When I visit the ‘Done’ filter
    Then I should see all the tasks I have submitted that have been rejected