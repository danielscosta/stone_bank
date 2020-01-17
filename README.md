# StoneBank

## To up the system

To run test and credo

`$ docker-compose run --rm test`

To run coveralls

`$ docker-compose run --rm test mix coveralls --umbrella`

Create database 

`$ docker-compose run web mix do ecto.create, ecto.migrate`

Run release of the phoenix server:

`$ docker-compose up release`

