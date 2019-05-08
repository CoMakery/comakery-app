Feature: Specifying who can work on tasks based on skill specialty
  ….

  Background:
    Given I am a project owner
    When I create a task with <batch type> batch type
    Then only contributors with <skill specialty> can see and start the task on My Tasks

  Scenarios:
  | batch type            | skill specialty |
  | Audio/Visual          | Audio/Visual |
  | Community Development | Community Development  |
  | Data Gathering        | Data Gathering  |
  | SM & Marketing        | SM & Marketing |
  | Software Developer    | Software Development |
  | UX / UI Design        | UX/UI Design |
  | Writing               | Writer |
