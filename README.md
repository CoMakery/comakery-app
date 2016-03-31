# CoMakery

Latest build: [![Circle CI](https://circleci.com/gh/CoMakery/comakery-app/tree/master.svg?style=svg)](https://circleci.com/gh/CoMakery/comakery-app/tree/master)

## Project Vision

CoMakery hangs out in Slack and creates Project Coins.
It helps you to distribute profit and tracks your fair share of projects you work on.
CoMakery helps you run a [Dynamic Equity Organization](https://github.com/citizencode/dynamic-equity-organization).

## Current Implementation Status

This project is alpha and not ready for production use.
It is being actively developed by CoMakery.
We welcome [feature requests and pull requests](https://github.com/comakery/comakery-app/issues).

We are planning to license it as a Dynamic Equity Organization.
The structure is being legally reviewed for use in CoMakery and on your projects.

## Local development

Prerequisites: PostgreSQL

```sh
bundle
rake db:create:all db:schema:load
rails server
```

## Ethereum development

Prerequisites:

```sh
npm i -g truffle  # version is currently in flux
npm i -g ethereumjs-testrpc
```

Run tests:

```
testrpc -p 7777
cd ethereum && truffle test
```

## Deleting a project

If you want to completely remove all trace of project `p` (be careful):

```ruby
p.award_types.each{|t| t.awards.destroy_all}
p.award_types.destroy_all
p.delete
```

## License

CoMakery is being developed under the experimental
[Peer Production Royalty Token License](https://github.com/comakery/comakery-app/blob/master/LICENSE.md).
