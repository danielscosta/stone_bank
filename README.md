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

## Test script (Local)

- Create User on http://localhost:4000/users/new without Bank Account (It will be your admin User)

- Change Column admin to true for you User on database

- Create another User with Bank Account

- Use Postman(Use StoneBank.postman_collection.json file) to call API and make what you want

- Do Login with your Admin User

- See the bank operation that you want
