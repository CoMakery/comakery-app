Feature: Reviewing, accepting and rejecting tasks
  ...

  Background:
    Given I am a logged in project owner
    And I am reviewing a submitted task

  Scenario: A project owner reviews task
    Then I should see the submitted work from the contributor

  Scenario: A project owner approves task
    When I approve the submitted task
    Then task becomes approved

  Scenario: A project owner rejects a task
    When I reject the submitted task
    Then task becomes rejected
