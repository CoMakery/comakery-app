Feature: Finding tasks

  Background:
    Given I am a logged in project owner
    And I am viewing my tasks
    And I want to see only Ready tasks

    # noah says: we should discuss this one - I'm not sure we want to show all the ready tasks. They can see them in the project settings page and this may create clutter.
  Scenario: A project owner should see all tasks from that project
    Given I have a project with tasks in ready state with different skills
    Then I should see all ready tasks from that project