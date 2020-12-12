include .env

start:
	docker-compose up -d

stop:
	docker-compose down

logs:
	docker-compose logs -f

git:
	docker-compose exec gocd-server ./scripts/git.sh $(SCM)

secure:
	docker-compose exec gocd-server ./scripts/secure.sh $(GOCD_USERNAME) $(GOCD_PASSWORD)

profiles:
	docker-compose exec gocd-server ./scripts/profiles.sh

encrypt:
	docker-compose exec gocd-server ./scripts/encrypt.sh $(SECRET)

repositories:
	docker-compose exec gocd-server ./scripts/repositories.sh

build:
	cd custom-agents && ./build.sh && cd ..

bash:
	docker-compose exec gocd-server bash

