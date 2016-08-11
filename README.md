# CoMakery

Latest build: [![Circle CI](https://circleci.com/gh/CoMakery/comakery-app/tree/master.svg?style=svg)](https://circleci.com/gh/CoMakery/comakery-app/tree/master)

## Project Vision

CoMakery hangs out in Slack and creates Project Coins.
It helps you to distribute profit and tracks your fair share of projects you work on.
CoMakery helps you run a [Dynamic Equity Organization](https://github.com/citizencode/dynamic-equity-organization).

## Current Implementation Status

This project is in private alpha.
It is being actively developed by CoMakery.

We are planning to license it as a Dynamic Equity Organization.
The structure is being legally reviewed for use in CoMakery and on your projects.

## Project management

Install the [zenbhub chrome git extension](https://chrome.google.com/webstore/detail/zenhub-for-github/ogcgkffhplmphkaahpmffcafajaocjbd?hl=en-US)

Then you can see the board at: https://github.com/CoMakery/comakery-app#boards?repos=51389241

## Local development

Prerequisites: PostgreSQL

add to `.env`:

```
RACK_ENV=development
PORT=3000
SLACK_API_KEY=[ask a teammate]
SLACK_API_SECRET=[ask a teammate]
APP_NAME=development

ETHEREUM_BRIDGE=http://localhost:3906
ETHERCAMP_SUBDOMAIN=morden
```

```sh
bundle
rake db:create:all db:schema:load
rails server
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
