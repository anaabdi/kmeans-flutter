.PHONY: build-web
build-web:
	flutter build web

.PHONY: firebase-deploy
firebase-deploy:
	firebase deploy

.PHONY: deploy
deploy: build-web firebase-deploy