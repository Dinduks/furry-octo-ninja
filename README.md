This is the application I use to share my code snippets (you can call them mini-tutorials) at http://snippets.dinduks.com.

Installation:

* Execute `bundle install`
* Setup your credentials as environment variables: `FURRY_USERNAME` and `FURRY_PASSWORD`
* Setup database info as environment variables also:
    - To use a SQLite database: `FURRY_DB_ADAPTER=sqlite3`.
    - To use a PostgreSQL database: `FURRY_DB_ADAPTER=postgres`, `FURRY_DB_NAME`, `FURRY_DB_HOST`, `FURRY_DB_USER` and `FURRY_DB_PASSWORD`.  
* Visit `/new` to add a new snippet

Example of setting environment variables for local development on Unix systems:
      export FURRY_USERNAME = "skullfist"
      export FURRY_PASSWORD = "nofalsemetal"
I suggest saving these in your `~/.bashrc` file.
