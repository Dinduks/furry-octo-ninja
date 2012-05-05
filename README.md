[![Build Status](https://secure.travis-ci.org/Dinduks/furry-octo-ninja.png?branch=master)](http://travis-ci.org/Dinduks/furry-octo-ninja)

This is the application I use to share my code snippets (you can call them mini-tutorials) at http://snippets.dinduks.com.

Installation:

* Execute `bundle install`
* Setup your credentials as environment variables: `FURRY_USERNAME` and `FURRY_PASSWORD`
* The application uses a SQLite database, if you want to use another RDBS, change `DATABASE_URL` environment variable to suit your needs.  
Example: `DATABASE_URL=postgres://username:password@host:port/database_name`. Don't forget installing the DataMapper adapter for your RDBS.
* Visit `/new` to add a new snippet

Example of setting environment variables for local development on Unix systems:
      export FURRY_USERNAME = "skullfist"
      export FURRY_PASSWORD = "nofalsemetal"
I suggest saving these in your `~/.bashrc` file.
