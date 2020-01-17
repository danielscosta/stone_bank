defmodule StoneBank.Accounts.Encryption do
  alias Bcrypt
  alias StoneBank.Accounts.User

  def hash_password(password), do: Bcrypt.hash_pwd_salt(password)

  def validate_password(%User{} = user, password), do: Bcrypt.verify_pass(user.password, password)
end
