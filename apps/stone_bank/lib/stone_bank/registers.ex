defmodule StoneBank.Registers do
  @moduledoc """
  The Registers context.
  """

  import Ecto.Query, warn: false
  alias StoneBank.Repo

  alias StoneBank.Registers.BankOperation

  @doc """
  Returns the list of bank_operations.

  ## Examples

      iex> list_bank_operations()
      [%BankOperation{}, ...]

  """
  def list_bank_operations do
    Repo.all(BankOperation)
  end

  @doc """
  Gets a single bank_operation.

  Raises `Ecto.NoResultsError` if the Bank operation does not exist.

  ## Examples

      iex> get_bank_operation!(123)
      %BankOperation{}

      iex> get_bank_operation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bank_operation!(id), do: Repo.get!(BankOperation, id)

  @doc """
  Creates a bank_operation.

  ## Examples

      iex> create_bank_operation(%{field: value})
      {:ok, %BankOperation{}}

      iex> create_bank_operation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bank_operation(attrs \\ %{}) do
    %BankOperation{}
    |> BankOperation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bank_operation changes.

  ## Examples

      iex> change_bank_operation(bank_operation)
      %Ecto.Changeset{source: %BankOperation{}}

  """
  def change_bank_operation(%BankOperation{} = bank_operation) do
    BankOperation.changeset(bank_operation, %{})
  end
end
