# CoMakery

Latest build: [![Circle CI](https://circleci.com/gh/CoMakery/swarmbot/tree/master.svg?style=svg)](https://circleci.com/gh/CoMakery/swarmbot/tree/master)

## Project Vision

CoMakery hangs out in Slack and creates Project Coins.
It helps you to distribute profit and tracks your fair share of projects you work on.
CoMakery helps you run a [Dynamic Equity Organization](https://github.com/citizencode/dynamic-equity-organization).

## Current Implementation Status

This project is alpha and not ready for production use.
It is being actively developed by CoMakery.
We welcome [feature requests and pull requests](https://github.com/comakery/swarmbot/issues).

We are planning to license it as a Dynamic Equity Organization.
The structure is being legally reviewed for use in CoMakery and on your projects.

## Interface Example

![CoMakery UX](https://cdn.rawgit.com/CoMakery/swarmbot/56606b5000c73549e0f775cd5062927ca14443d1/doc/designs/project.png)

## Local development

Prerequisites: PostgreSQL

```sh
bundle
rake db:create:all db:schema:load
rails server
```

## License

CoMakery is being developed under the experimental
[Peer Production Royalty Token License](https://github.com/comakery/swarmbot/blob/master/LICENSE.md).
