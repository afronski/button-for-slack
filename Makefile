all: install

install:
	virtualenv venv --no-site-packages --python=python2.7
	venv/bin/python -m pip install -r requirements.txt
	npm install

clear:
	rm -rf venv/
