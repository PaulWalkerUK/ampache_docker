# Ampache Docker
This is a very personalised Docker for Ampache.

It includes Ampache running on Apache and PHP, but _does not_ include the
database - this needs to be already setup somewhere else.

## To start the container

`$ docker run -v /path_to_media:/media -p 8080:80 -e database.host="db_host" -e database.port="3307" -e database.name="ampache_db" -e database.username="ampache" -e database.password="Password_12345" PaulWalkerUK/ampache`
