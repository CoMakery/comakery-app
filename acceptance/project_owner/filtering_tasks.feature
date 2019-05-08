Feature: Filtering tasks
  ...

  Background:
    Given I am a logged in project owner
    And I am viewing my tasks

  Scenario Outline: A project owner can filter tasks
    Given I have Ready, Submitted, Accepted, Paid, Rejected tasks as a project owner
    When I want to see only <filter> tasks
    Then I should see only <statuses> tasks

    Scenarios:
      | filter    | statuses       |
      | ready     | ready          |
      | started   | no             |
      | submitted | no             |
      | to review | submitted      |
      | to pay    | accepted       |
      | done      | paid, rejected |
