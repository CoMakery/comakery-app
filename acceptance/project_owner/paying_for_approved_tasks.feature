Feature: Paying for accepted tasks

Background:
Given I am a project owner
And I am viewing tasks which I need to pay for

Scenario: A project owner pays task
When I pay the contributor for an accepted task
Then I should see all relevant award details
And my wallet should be open to make the payment
And the task status should become paid
And the task contributor should receive an email confirmation
