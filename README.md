# CoMakery

## Project Vision

CoMakery creates Project Tokens and notifies your team via Slack.
It helps you to distribute profit and tracks your fair share of projects you work on.

## Current Implementation Status

This project is in open beta.
It is being actively developed by CoMakery.

## Local development

Prerequisites:

- PostgreSQL
- Redis is you want to run delayed jobs

Set up .env:

```sh
cp .env.dev .env
heroku config -a <YOUR_HEROKU_APP> -s | egrep '^(SLACK_|ETHEREUM_|ETHERCAMP_)' | sort >> .env
```

Basics :

```sh
bundle
rake db:create:all db:schema:load
```

Run server:

```sh
rails server
```

or if you want to run with delayed jobs:

```sh
bin/server
```

## Running tests

A bit faster: `bin/rspec`

More thorough (integrates views): `bin/rspect`

## Pushing code to Github

To run your tests and git push your branch *only if tests pass*, run `bin/shipit`.

## Deploying to heroku

Once your heroku user has access to the applications, you can run any of:

```
bin/deploy staging
bin/deploy production
```

## Basic Auth

Set an environment variable called `BASIC_AUTH` in the format
`<username>:<password>` (e.g., `chewie:r0000ar`). Basic auth will be enabled if
that environment variable exists.

## Sidekiq

Visit <COMAKERY_INSTANCE>/admin/sidekiq

Username admin, password is in heroku app settings

## Scheduled Jobs

On staging and production, we use Heroku Scheduler to run `rails runner bin/patch_ethereum_awards`
on a daily basis.  This task backfills "pending" ethereum awards, if they are no longer retired by Sidekiq.

## Github Importer

To create an an award for each git commit in a github project, start by running this command:  
```
importer/git_importer.rb --help                             # local
heroku run -r staging "importer/git_importer.rb --help"     # staging
```

Study the options in help, then construct a command.

**Use only with great care on production!**
If you mistype the project ID, you will import awards into the wrong project.

A full sample command:
```
heroku run -r staging "importer/git_importer.rb --github-repo core-network/client --project-id 1 --ethereum"
```

## Deleting a project

If you want to completely remove all trace of project `p` (be careful):

```ruby
p.award_types.each{|t| t.awards.destroy_all}
p.award_types.destroy_all
p.delete
```
