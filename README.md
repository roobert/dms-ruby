## About

A *push based* dead mans switch for prometheus and alertmanager - PoC

## Install

Dependencies:
```
rake install
```

## Run

API:
```
rake api
```

Alerter:
```
CLIENTS="<host0>,<host1>,..." \
SLACK_WEBHOOK="http://..." \
SLACK_USERNAME="dms" \
SLACK_CHANNEL="#alerts" \
  rake alerter
```
