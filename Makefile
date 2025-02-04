setup: setup-projects setup-secrets

setup-projects:
	./setup-projects.sh

setup-secrets:
	./setup-secrets.sh
	./copy-secrets.sh
