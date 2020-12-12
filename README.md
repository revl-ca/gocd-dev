# gocd-server

## Procedures

### Install/Start GoCD

`make start`

### Build custom agents

`make build`

### Install GIT credentials

`make git`

### Install profiles

`make profiles`

### Install repositories

`make repositories`

## Misc.

### Secure the Login

`GOCD_USERNAME=<username> GOCD_PASSWORD=<password> make secure`

**ENABLING THIS MAKE YOU UNABLE TO PROVISION WITH SCRIPTS**

### Stop GoCD

`make stop`

### Generate secret

`SECRET=<your-sensitive-value> make encrypt`

