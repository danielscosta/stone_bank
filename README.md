# StoneBank

## To up the system

Create database 

`$ docker-compose run web mix do ecto.create, ecto.migrate`

To run test and credo

`$ docker-compose run --rm test`

To run coveralls

`$ docker-compose run --rm test mix coveralls --umbrella`

Run release of the phoenix server:

`$ docker-compose up release`

