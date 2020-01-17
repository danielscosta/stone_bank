defmodule StoneBank.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias StoneBank.Repo

  alias StoneBank.Products.BankAccount

  @doc """
  Gets a single bank_account.

  Raises `Ecto.NoResultsError` if the Bank account does not exist.

  ## Examples

      iex> get_bank_account!(123)
      %BankAccount{}

      iex> get_bank_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bank_account!(id), do: Repo.get!(BankAccount, id)

  @doc """
  Creates a bank_account.

  ## Examples

      iex> create_bank_account(%{field: value})
      {:ok, %BankAccount{}}

      iex> create_bank_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bank_account(attrs \\ %{}) do
    %BankAccount{}
    |> BankAccount.changeset(attrs)
    |> Repo.insert()
  end

  alias Ecto.Multi
  alias StoneBank.Registers

  @doc """
  Deposit in a bank_account.

  ## Examples

      iex> deposit_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:ok, %{update_bank_account: %{1, _}, back_operation: back_operation}}

      iex> deposit_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:ok, %{update_bank_account: %{0, _}}}

  """
  def deposit_bank_account(%{value: value, bank_account_id: bank_account_id}) do
    Multi.new()
    |> Multi.run(:update_bank_account, fn repo, _changes ->
      from(ba in BankAccount,
        where: ba.bank_account_id == ^bank_account_id,
        update: [set: [balance: ba.balance + ^value]]
      )
      |> repo.update_all([])
    end)
    |> Multi.run(:back_operation, fn _repo, %{update_bank_account: update_bank_account} ->
      case update_bank_account do
        {1, _} ->
          Registers.create_bank_operation(%{
            value: value,
            type: "deposit",
            bank_account_id: bank_account_id
          })
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Withdraw in a bank_account.

  ## Examples

      iex> withdraw_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:ok, %{update_bank_account: %{1, _}, back_operation: back_operation}}

      iex> withdraw_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:ok, %{update_bank_account: %{0, _}}}

  """
  def withdraw_bank_account(%{value: value, bank_account_id: bank_account_id}) do
    Multi.new()
    |> Multi.run(:update_bank_account, fn repo, _changes ->
      from(ba in BankAccount,
        where: ba.bank_account_id == ^bank_account_id and ba.balance - ^value >= 0,
        update: [set: [balance: ba.balance - ^value]]
      )
      |> repo.update_all([])
    end)
    |> Multi.run(:back_operation, fn _repo, %{update_bank_account: update_bank_account} ->
      case update_bank_account do
        {1, _} ->
          Registers.create_bank_operation(%{
            value: value,
            type: "withdraw",
            bank_account_id: bank_account_id
          })
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Transfer cash between bank_accounts.

  ## Examples

      iex> transfer_bank_account(%{value: value, bank_account_id: bank_account_id, bank_account_destiny_id: bank_account_destiny_id})
      {:ok, %{update_bank_account: %{1, _}, update_bank_account_destiny: %{1, _}, back_operation: back_operation}}

      iex> transfer_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:ok, %{update_bank_account: %{0, _}}}

  """
  def transfer_bank_account(%{
        value: value,
        bank_account_id: bank_account_id,
        bank_account_destiny_id: bank_account_destiny_id
      }) do
    Multi.new()
    |> Multi.run(:update_bank_account, fn repo, _changes ->
      from(ba in BankAccount,
        where: ba.bank_account_id == ^bank_account_id and ba.balance - ^value >= 0,
        update: [set: [balance: ba.balance - ^value]]
      )
      |> repo.update_all([])
    end)
    |> Multi.run(:update_bank_account_destiny, fn repo,
                                                  %{update_bank_account: update_bank_account} ->
      case update_bank_account do
        {1, _} ->
          from(ba in BankAccount,
            where: ba.bank_account_id == ^bank_account_id,
            update: [set: [balance: ba.balance + ^value]]
          )
          |> repo.update_all([])
      end
    end)
    |> Multi.run(:back_operation, fn _repo,
                                     %{update_bank_account_destiny: update_bank_account_destiny} ->
      case update_bank_account_destiny do
        {1, _} ->
          Registers.create_bank_operation(%{
            value: value,
            type: "transfer",
            bank_account_id: bank_account_id,
            bank_account_destiny_id: bank_account_destiny_id
          })
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bank_account changes.

  ## Examples

      iex> change_bank_account(bank_account)
      %Ecto.Changeset{source: %BankAccount{}}

  """
  def change_bank_account(%BankAccount{} = bank_account) do
    BankAccount.changeset(bank_account, %{})
  end
end
