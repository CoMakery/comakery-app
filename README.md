[![CoMakery](./public/Logo-Header.svg)](https://www.comakery.com)

## CoMakery Helps You Gather a Tribe To Achieve Big Missions. 

To achieve your big mission you need to bring people together around a common vision, let them know what they will get by contributing, and organize the work. The CoMakery platform helps you do this with missions, projects, task workflows, tokens & payments.

[![About CoMakery](./public/video-preview.png)](https://vimeo.com/345071697)

## Getting Started
* [Join the CoMakery Community](https://www.comakery.com) - follow some projects, get to know us.
* [Join the CoMakery Forum](https://forum.comakery.com) - chat with the CoMakery community
* [Using the CoMakery platform](http://support.comakery.com/en/collections/2015024-getting-started-on-comakery)
* [Launching a project on CoMakery](http://support.comakery.com/en/collections/2013276-launching-a-project)
* [The CoMakery REST API](https://www.comakery.com/doc/api/v1/index.html)
* [CoMakery Security Token (Open Source MIT Licensed ERC-1404)](https://github.com/CoMakery/comakery-security-token)
* [Setting up the CoMakery platform development environment](#development-setup) 

## Try Out CoMakery

You can join the CoMakery community and try using the platform for free at [CoMakery.com](https://www.comakery.com) or host your own version for your community.

## Free For Noncommercial Use

Our [license](LICENSE.md) allows you to use and share this software for noncommercial nonviolent purposes for free and to try this software for commercial nonviolent purposes for thirty days. If you are an academic, environmental organizer, hobbyist community builder or non-profit we are proud to support the work you do with free use of CoMakery. Thank you for your hard work towards benefitting society.

## 30 Day Free Commercial Trial

If you are a company [our license](LICENSE.md) allows you to use this software for free for thirty days.

Get in touch with CoMakery at [support@comakery.com](mailto:support@comakery.com) about: 
* A commercial license for self-hosting
* Customization of the software for your community
* White label hosting
* Coop & L3C license discount

Your payments help support the philanthropic organizations who use the platform for free.

## Improving The Software

You are free to modify the software. We'd love it if you share your code back with the community, but you are not obligated to.

If you need help customizing the software get in touch with CoMakery about customization services: [support@comakery.com](mailto:support@comakery.com)

There's no restriction on receiving money to improve the software. If you are a software developer or software development company we look forward to improving the platform and serving the community with you.

Chat with us on the [CoMakery Forum](https://forum.comakery.com) about features and improvements.

## Get Involved

We will be using CoMakery to build CoMakery! 

Here's where you can connect with the community:
* Join CoMakery and hit the follow button on the [CoMakery MetaProject](https://www.comakery.com/projects/2)
* Create a GitHub issue or comment on one
* Chat with us on the [CoMakery Forum](https://forum.comakery.com)

# Deploying CoMakery Server

You can deploy the server using the deploy to Heroku Button which relies on the `app.json`. You can also deploy the app using the docker file similarly to the docker development environment setup.

## What Branch Should I Deploy From?

You should deploy from the `master` branch. New code is merged into the `acceptance` branch for QA checks before getting merged into `master`.

## Deploying to Heroku with app.json

If you want to deploy a new a new CoMakery Server on Heroku just press this button:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-app)

- During setup update API keys and secrets according to environment
- After deployment manually update formation and addons plans according to environment
- Re-run migrations using Heroku CLI, if `heroku-postgresql` plan is upgraded from `hobby-dev`
- Setup DNS and add SSL 
- Update Cloudfront and Airbrake settings

## Basic Auth

Set an environment variable called `BASIC_AUTH` in the format
`<username>:<password>` (e.g., `chewie:r0000ar`). Basic auth will be enabled if
that environment variable exists.

# Development Setup

CoMakery is written for Ruby on Rails, React, Postgres, MetaMask, Ethereum and other blockchains.
  
## Configuration

We use environment variables for app "secrets", and values which vary between environments - such as staging and production. Locally these are stored in a `.env` file at the root of the project. **Don't commit your .env file to any GitHub repository.** On heroku environment variables are defined using [Heroku Config Vars](https://devcenter.heroku.com/articles/config-vars).

## Local development with Docker
#### Setup development environment
```
$ docker-compose run runner bundle exec ./bin/setup
```

#### Example: Running the app
```
$ docker-compose run --service-ports rails
$ docker-compose run --service-ports webpacker
$ docker-compose run --service-ports sidekiq
```

#### Example: Attaching console and running specs
```
$ docker-compose run runner
$ RAILS_ENV=test bundle exec rspec
$ NODE_ENV=test yarn test
```

## Local Development Without Docker

Prerequisites:

- PostgreSQL
- Redis (if you want to run delayed jobs)
- Bundler
- Yarn
- Chrome and [Chromedriver](https://chromedriver.chromium.org/)

To insall chromedriver on OS X use: `brew cask install chromedriver`. Rspec specs will fail if you have an earlier or mismatched version.

Here's a complicated but possibly useful chromedriver reference setup. [Reference setup](https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/ruby/images/2.4.4-stretch/browsers/Dockerfile)

Set up .env:

```sh
cp .env.dev .env
heroku config -a <YOUR_HEROKU_APP> -s | egrep '^(SLACK_|ETHEREUM_|ETHERCAMP_)' | sort >> .env
```

Basics :

```sh
source .env
bundle install
yarn install
rails db:setup
rails data:migrate
```

Run server:

```sh
rails server
```

To render css and js assets faster run:
```
bin/webpack-dev-server 
```

If you need development seed data - DO NOT RUN ON PRODUCTION:
```
rake db:seed
```

If you are having trouble with emails not finding the correct host set the `APP_HOST` variable in your `.env` file.

For example in development you will probably want to set it to:
```
APP_HOST=localhost:3000
```

And sign in with:
login: dev@dev.dev
password: dev

or if you want to run with delayed jobs:

```sh
bin/server
```

Enable caching (required for Metamask Auth and Rack-Attack):
```sh
rails dev:cache
```
## React on Rails

###  Webpacker

For development, run `bin/webpack-dev-server` command in a terminal separate from `rails s` so that the changes made inside react components are updated real time.
However for production, we will use precompiled react code so we don't need to run webpack-dev-server for production mode.
And Webpacker hooks up a new webpacker:compile task to assets:precompile, which gets run whenever you run assets:precompile.
So after running assets precompile, all react components will be working in production mode.

### React_Rails

All react components should be inside `app/javascript/components`. 
Use the `react_component` helper to render react component with `<%= react_component "Account" %>`.

https://github.com/reactjs/react-rails

## Running tests

Faster test runs with: `bin/rspec`

More thorough test runs (integrates views): `bin/rspect`

JS tests via Jest: `yarn test`
Run the linters with: `yarn lint`
Update JS test fixtures with: `yarn jest --updateSnapshot`

Run Rubocop Ruby code metrics with: `bin/rubocop`

## Code Commit and Deployment Workflow

* Develop your code locally in a git feature branch
* `bin/shipit` to git push your branch to GitHub *only if tests and quality checks pass*. This runs the same checks that CircleCI will run after you push your code to GitHub.
* On GitHub, create a pull request from your feature Branch to the `acceptance` branch
* Get your code reviewed by at least one CoMakery person
* Noah <@aquabu> will do a final review and merge your PR to `acceptance`
* Code merged to `acceptance` is automatically deployed to `demo.comakery.com` for QA
* Once code is tested by CoMakery's QA team it is manually merged to `master`
* If CI passes on master, master is manually deployed to `staging.comakery.com` for final review
* If the code looks good on staging then it is manually deployed to `www.comakery.com`

## Deploying to Heroku Environments

### `bin/deploy heroku-app [git-ref]`

Example usage:
```
# deploy HEAD of current branch to staging
bin/deploy comakery-staging

# deploy the git ref called hot-fix-branch to staging
bin/deploy comakery-staging hot-fix-branch
```

The `bin/deploy` script does the following:
1. Turn on the down for maintenance page
2. Manually backup production
3. Deploy the git code in the current local branch to the heroku app specified
4. Run `rake db:migrate`
5. Run `rake data:migrate` to migrate data
6. Restart the apps with `heroku restart`
7. Turn off the down for maintenance page 

## Data migrations

We are using the data-migrate gem to load static table data or transform data. data migrate works similarly to schema migrations - they run in sequence, are run only once, track the last database migration that was run in the database, and can be run with rake.

Data migration scripts are located in `db/data_migrations`. 

If you need to migrate data or add static table data run
```
rake data:migrate
```

To generate a new data migration run
```
rails g data_migration add_this_to_that
```

More documentation is [here](https://github.com/ilyakatz/data-migrate)

## Schema Overview

Mostly up to date partial overview of table relationships.

![new schema](doc/schema-with-batches/skill-interest-schema.png)

## Blockchain Transactions Schema Overview

![schema](doc/blockchain-transactions.svg)

## API documentaion

API documentaion is generated with `rspec_api_documentation` gem from [spec/acceptance](./spec/accpetance/) specs

See [config/initializers/rspec_api.rb](./config/initializers/rspec_api.rb) for configuration

Generated HTML is located in `/public/doc/api` directory and accessible on https://www.comakery.com/doc/api/v1/index.html

You can generate the docs with
```
rails docs:generate
```
