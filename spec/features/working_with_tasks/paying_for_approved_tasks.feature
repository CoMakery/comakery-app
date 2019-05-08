Feature: Paying for approved tasks
  ...

  Background:
    Given I am a logged in project owner
    And I am viewing the To Pay filter on My Tasks

  Scenario: A project owner pays task
    When I click pay contributor on an accepted task
    Then I should be taken to the awards screen
    And all relevant details will be pre-populated
