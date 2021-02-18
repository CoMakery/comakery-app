# Hotwallet

### Deploy to Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CoMakery/comakery-server/tree/hotwallet)

### Setup development enviroment:
```shell
yarn install
cp .env.example .env
```

Change ENV variables to actual in `.env` file.

### Manage process:
```shell
bin/start   # Start hotwallet
bin/stop    # Stop hotwallet
bin/restart # Restart hotwallet
bin/list    # List processes
bin/logs    # Show logs
```

### Run tests:
```shell
yarn test
```
