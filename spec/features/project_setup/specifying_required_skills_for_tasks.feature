Feature: Specifying who can work on tasks based on skill specialty

Background:
Given I am a project owner

Scenario:
When I create a task with general batch type
Then it should be available to all contributors

Scenario:
When I create a task with a specialized batch type
Then it should be available to only contributors with that skill
