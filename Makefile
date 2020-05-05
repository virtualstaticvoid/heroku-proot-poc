# default target
all::

.PHONY: all
all:: build

ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz:

	# get ubuntu image
	curl -sLO https://cloud-images.ubuntu.com/minimal/releases/bionic/release/ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz

.heroku-app-info.json:

	# provision heroku app
	heroku create --buildpack https://github.com/niteoweb/heroku-buildpack-shell.git
	heroku apps:info -j > .heroku-app-info.json

.PHONY: build
build: ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz

	# build docker image
	docker build --tag vsv/proot-tests .

.PHONY: deploy
deploy: .heroku-app-info.json

	# deploy heroku app
	git push heroku master
