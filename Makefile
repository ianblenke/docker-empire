all:
	docker build -t ianblenke/empire .
	docker run -ti --rm --name empire -p 3000:3000 -p 6665:6665 ianblenke/empire
