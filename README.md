## About

This is *push based* dead mans switch for prometheus and alertmanager - PoC

## Install

Dependencies:
```
apt install libsqlite3-dev sqlite3
gem install bundle
bundle install
```

## Run

API:
```
rackup
```

Alerter:
```
WEBHOOK_URL="http://..." ./alerter.rb
```
