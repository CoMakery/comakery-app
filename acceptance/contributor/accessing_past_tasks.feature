Feature: Accessing past tasks

  Background:
    Given I am a logged in contributor
    And I am viewing my past tasks

  Scenario: A contributor see tasks they been paid for
    Then I should see all the tasks I have been paid for

  Scenario: A contributor see tasks that have been rejected
    Then I should see all the tasks I have submitted that have been rejected
