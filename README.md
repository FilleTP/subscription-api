# README

SUBSCRIPTION API

* Ruby version
    3.1.0

* Configuration
    ```
    git clone git@github.com:FilleTP/subscription-api.git
    cd subscription-api

    bundle install
    ```
* Database creation
    ```
    rails db:create
    rails db:migrate
    ```
* How to run the test suite
    ```
    rspec
    ```
    - Test include models, use cases and services
    - Test uses Rspec and FactoryBot

* Services (job queues, cache servers, search engines, etc.)
    - API implementation of adding and removing coupons from subscriptions
    - Uses design pattern UseCase and Services
    - HTTParty used for external API calls

* Implementation details
    - Simple Authentication to the app is done with a distributed API key
    - This Rails API relies on external systems to verify and authorize users and their
    - ownership of Subscription records
    - Consistent json responses are provided from all endpoints
    - Consistent Logging is used to ease debugging and issue resolution 

* Future Development
    - Additional Endpoints for Subscription CRUD
    - Additional Endpoints for Coupons CRUD
    - URL whitelisting in Application Controller
    - Rate Limiting and RackAttack
