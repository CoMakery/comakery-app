Feature: Finding tasks

  Background:
    Given I am a logged in user
    And I am viewing my tasks
    And I want to see only Ready tasks

  Scenario: A project owner should see all tasks from that project
    Given I have a project with tasks in ready state with different skills
    Then I should see all ready tasks from that project

  Scenario: A contributor from project communication channel should see all tasks from that project
    Given I belong to a communication channel of a project with tasks in ready state with different skills
    Then I should see all ready tasks from that project

  Scenario: A contributor should see only tasks matching his skill or tasks with General skill
    Given there’s a public project with tasks in ready state with different skills
    Then I should see only tasks with my skill
    But I should also see tasks with General skill