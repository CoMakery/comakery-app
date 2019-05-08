Feature: Specifying who can work on tasks based on tasks completed

Background:
Given I am a project owner

  # noah says: does this duplicate other specifications? Maybe not but worth talking about.
Scenario:
When I create a task that does not require past experience
Then it should be available to all contributors

Scenario:
When I create a task with some experience required
Then it should be available to only contributors having that experience
