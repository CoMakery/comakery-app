[![CoMakery](./public/Logo-Header.svg)](https://comakery.com)

## CoMakery helps you gather a tribe to achieve big missions. 

To achieve your big mission you need to bring people together around a common vision, let them know what they will get by contributing, and organize the work. The CoMakery platform helps you do this with missions, projects, task workflows, tokens & payments.

[![About CoMakery](./public/video-preview.png)](https://vimeo.com/345071697)

## Getting Started
* [Using the CoMakery platform](http://support.comakery.com/en/collections/2015024-getting-started-on-comakery)
* [Launching a project on CoMakery](http://support.comakery.com/en/collections/2013276-launching-a-project)
* [The CoMakery REST API](https://www.comakery.com/doc/api/index.html)
* [CoMakery Security Token (Open Source ERC-1404)](https://github.com/CoMakery/comakery-security-token)
* [Setting up the CoMakery platform development environment](#local-development) 

## Try out CoMakery

You can join the CoMakery community for free at [CoMakery.com](https://www.comakery.com) or host your own version for your community.

## Free For Non-Commercial Use
[Our license](LICENSE.md) allows you to use, modify and share this software for non-commercial purposes for free. If you are an academic, environmental organizer, hobbyist community builder or non-profit we are proud to support the work you do by allowing you free use of CoMakery. Thank you for your hard work towards benefitting society.

## 30 Day Free Commercial Trial

If you are a company [our license](LICENSE.md) allows you to use this software for thirty days.

Get in touch with CoMakery at [noah@comakery.com](mailto:noah@comakery.com) about: 
* A commercial license for self-hosting
* White label hosting
* Platform customization
* Coop discount

Your payments help support the philanthropic organizations who use the platform for free. 

## Get Involved

We will be using CoMakery to build CoMakery! 

Here's where you can connect with the community:
* Join CoMakery and hit the follow button on the [CoMakery MetaProject](https://www.comakery.com/projects/2)
* Create a GitHub issue or comment on one 

# Development Setup

CoMakery is written for Ruby on Rails, React, Postgres, MetaMask, Ethereum and other blockchains.
  
## Configuration

We use environment variables for app "secrets", and values which vary between environments - such as staging and production.

## Install

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
* Get your code reviewed by at least one person
* Merge your PR to `acceptance`
* Code merged to `acceptance` is automatically deployed to `demo.comakery.com` on Heroku for QA
* Once code is tested it is manually merged to `master`
* If CI passes on master, master is manually deployed to `staging.comakery.com` on Heroku
* If the code looks good on staging then it is manually deployed to `www.comakery.com` on Heroku

## Deploying to Heroku Environments

### `bin/deploy heroku-app [git-ref]`

Example usage:
```
# deploy HEAD of current branch to staging
bin/deploy comakery-staging

# deploy the git ref called hot-fix-branch to staging
bin/deploy comakery-staging hot-fix-branch

# deploy HEAD of current branch to production
bin/deploy comakery-production
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


## Basic Auth

Set an environment variable called `BASIC_AUTH` in the format
`<username>:<password>` (e.g., `chewie:r0000ar`). Basic auth will be enabled if
that environment variable exists.

## Deploying to Heroku with app.json

This is useful if you want to create a new environment.

- [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-app)
- During setup update API keys and secrets according to environment
- After deployment manually update formation and addons plans according to environment
- Re-run migrations using Heroku CLI, if `heroku-postgresql` plan is upgraded from `hobby-dev`
- Setup DNS and install following addons in case of production or staging environment:
  - https://elements.heroku.com/addons/ssl
  - https://elements.heroku.com/addons/expeditedssl
- Update Cloudfront and Airbrake settings

## Sidekiq

Visit <COMAKERY_INSTANCE>/admin/sidekiq

Username admin, password is in heroku app settings

### Clear and regenerate dead sidekiq jobs

If you are getting an out of memory error for Redis. The processed queue can take up a lot of memory. It can be cleared with `Sidekiq::Stats.new.reset`

If the queue gets backed up or the regenerate script starts duplicating jobs, you can clear it out the Sidekiq job queue by running:

```
Sidekiq::Queue.all.each(&:clear)
Sidekiq::RetrySet.new.clear
Sidekiq::ScheduledSet.new.clear
Sidekiq::Stats.new.reset
Sidekiq::DeadSet.new.clear
```

### Redis Configuration On Heroku

You can find the configuration details at the Heroku Overview Redis To Go link. Notice that this is **redis to go** and **NOT Heroku Redis**. This means that Heroku Redis commands will not work.

You might get an error like `Redis::CommandError: OOM command not allowed when used memory > 'maxmemory'.`

To remove old keys you can do the following. Use the correct environment for your needs.

```
heroku addons -a comakery-staging
```

You will see something like:
```
redistogo (redistogo-spherical-15306)          micro        $5/month   created
 └─ as REDISTOGO
```

More info with:
```
heroku addons:info redistogo-spherical-15306
```

### Flushing Redis Directly

Hopefully you won't need this...

Consider clearing out the Sidekiq Redis jobs using the `Sidekiq::Queue.all.each(&:clear)` and related Sidekiq methods as described in other sections.

You can connect to Redis To Go CLI with:
```
redis-cli -h lab.redistogo.com -p 9968 -a [password]
```

To flush the old keys
```
lab.redistogo.com:9968> flushdb
```

## Schema Overview

Mostly up to date partial overview of table relationships.

![new schema](doc/schema-with-batches/skill-interest-schema.png)

## Blockchain Transactions Schema Overview

![schema](doc/blockchain-transactions.svg)

## API documentaion

API documentaion is generated with `rspec_api_documentation` gem from `spec/acceptance/*` specs

See `config/initializers/rspec_api.rb` for configuration

Generated HTML is located in `/public/doc/api` directory and accessible on `https://www.comakery.com/doc/api/index.html` 

```
rails docs:generate
```
