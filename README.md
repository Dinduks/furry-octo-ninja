[![Build Status](https://secure.travis-ci.org/Dinduks/furry-octo-ninja.png?branch=master)](http://travis-ci.org/Dinduks/furry-octo-ninja)

I use this application to share my code snippets at http://snippets.dinduks.com.

##### Installation

* Execute `bundle install`
* Setup your credentials as environment variables in a *.env* file:

    ```
    FURRY_USERNAME=skullfist
    FURRY_PASSWORD=nofalsemetal
    ```

* The application uses a SQLite database, if you want to use another RDBS, change `DATABASE_URL` environment variable to suit your needs.  
Example: `DATABASE_URL=postgres://username:password@host:port/database_name`. Don't forget installing the DataMapper adapter for your RDBS.

##### Use
* Visit `/new` to add a new snippet
* Visit `/:snippet/edit` to edit it
* Visit `/:snippet/delete` to delete it

##### Google Analytics
If you want to use Google Analytics, simply set the `GA_TRACKING_CODE` and `GA_SITE`
environment variables.
