Feature: Accessing past tasks

  Background:
    Given I am a logged in user
    And I am viewing my past tasks

  Scenario: A project owner see tasks they have paid for
    Then I should see all the tasks I have paid out

  Scenario: A project owner see tasks they have rejected
    Then I should see all the tasks I have rejected

  Scenario: A contributor see tasks they been paid for
    Then I should see all the tasks I have been paid for

  Scenario: A contributor see tasks that have been rejected
    Then I should see all the tasks I have submitted that have been rejected
