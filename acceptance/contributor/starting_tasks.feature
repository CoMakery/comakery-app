Feature: Starting tasks
  ...

  Background:
    Given I am a logged in user
    And I am viewing the ready filter on my tasks
    And there’s a task available for me as a contributor

  Scenario: A user can start a task from My Tasks
    When I want to start the task
    Then the task status should be started
