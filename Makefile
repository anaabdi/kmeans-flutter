.PHONY: build-web
build-web:
	flutter build web

.PHONY: firebase-deploy
firebase-deploy:
	firebase deploy

.PHONY: deploy
deploy: build-web firebase-deploy

.PHONY: run-html
run-html:
	flutter run -d chrome --web-renderer html

.PHONY: run
run:
	flutter run -d chrome