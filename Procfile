web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -v -C ./config/sidekiq.yml
release: bin/rails db:prepare
