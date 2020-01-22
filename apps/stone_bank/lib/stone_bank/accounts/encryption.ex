defmodule StoneBank.Accounts.Encryption do
  @moduledoc """
   This module encrypt user password to save in database and verify if passed on login password is the same than stored.
  """
  alias Bcrypt
  alias StoneBank.Accounts.User

  def hash_password(password), do: Bcrypt.hash_pwd_salt(password)

  def validate_password(%User{} = user, password),
    do: Bcrypt.verify_pass(password, user.encrypted_password)
end
