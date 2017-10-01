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
CLIENTS="<host0>,<host1>,..." SLACK_WEBHOOK="http://..." SLACK_USERNAME="dms" SLACK_CHANNEL="#alerts" ./alerter.rb
```
