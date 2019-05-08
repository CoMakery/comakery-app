Feature: Viewing task details
  ...

  Background:
    Given I am a logged in user
    And I am viewing my tasks
    And there’s a task available for me

  Scenario: A user can go to task details from My Tasks
    When I want to see task details
    Then I should see task details
