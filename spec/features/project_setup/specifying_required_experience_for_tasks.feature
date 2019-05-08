Feature: Specifying who can work on tasks based on tasks completed

Background:
Given I am a project owner

Scenario:
When I create a task without an experience required
Then it should be available to all contributors

Scenario:
When I create a task with an experience required
Then it should be available to only contributors having that experience
