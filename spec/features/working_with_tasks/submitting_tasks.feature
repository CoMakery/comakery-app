Feature: Submitting tasks
  ...

  Background:
    Given I am a logged in contributor that has started a task
    And I open a started task details as a contributor

  Scenario: A contributor can submit work for the task
    When I submit the work with valid data
    Then the task status should be submitted

  Scenario: A contributor receives an error when submitting work for the task incorrectly
    When I submit the task with invalid or missing data
    Then the task status shouldn't be submitted
    And I should see an error

  Scenario: A contributor cancels task submission
    When I cancel task submission
    Then the task status shouldn't be submitted
    And I should see my tasks
