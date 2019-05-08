Feature: Specifying who can work on tasks based on tasks completed
  ….

  Background:
    Given I am a project owner
    When I create a task I want to specify what previous work contributors must have completed to qualify for this task
    Then the task should be available to all contributors that meet those qualifications

  Scenario Outline: A project owner wants to restrict who can work on their task
    Given I am a project owner creating a task
    And I want contributors with <completed tasks> in their work history
    Then contributors that have <skill confirmation> can work on this task

    Scenarios:
      | completed tasks | skill confirmation      |
      | 0 -2            | New Contributor         |
      | 0 - 2           | Demonstrated Skills     |
      | 3 - 10          | Demonstrated Skills     |
      | 0 - 2           | Established Contributor |
      | 3 - 10          | Established Contributor |
      | 11 - ∞          | Established Contributor |
