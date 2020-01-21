defmodule StoneBank.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias StoneBank.Repo
  require Logger

  alias StoneBank.Products.BankAccount

  @doc """
  List bank_account by user_id.

  ## Examples

      iex> list_bank_account_user_id(user_id)
      [%BankAccount{}]

  """
  def list_bank_account_user_id(user_id) do
    BankAccount
    |> where([b], b.user_id == ^user_id)
    |> Repo.all()
  end

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
      {:ok, %{update_bank_account: 1, back_operation: back_operation}}

      iex> deposit_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:error, _}

  """
  def deposit_bank_account(%{value: value, bank_account_id: bank_account_id, user_id: user_id}) do
    Multi.new()
    |> Multi.run(:update_bank_account, fn repo, _changes ->
      {number, nil} =
        from(ba in BankAccount,
          where: ba.id == ^bank_account_id and ba.user_id == ^user_id,
          update: [set: [balance: ba.balance + ^value]]
        )
        |> repo.update_all([])

      {:ok, number}
    end)
    |> Multi.run(:back_operation, fn _repo, %{update_bank_account: update_bank_account} ->
      case update_bank_account do
        1 ->
          Registers.create_bank_operation(%{
            value: value,
            type: "deposit",
            bank_account_id: bank_account_id
          })

        _ ->
          {:error, nil}
      end
    end)
    |> Multi.run(:send_email, fn _repo, %{back_operation: back_operation} ->
      ## Here will be the send of a email
      Logger.info(
        "Back Account Deposit made #{back_operation.bank_account_id}: #{back_operation.value}"
      )

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """
  Withdraw in a bank_account.

  ## Examples

      iex> withdraw_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:ok, %{update_bank_account: 1, back_operation: back_operation}}

      iex> withdraw_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:error, _}

  """
  def withdraw_bank_account(%{value: value, bank_account_id: bank_account_id, user_id: user_id}) do
    Multi.new()
    |> Multi.run(:update_bank_account, fn repo, _changes ->
      {number, nil} =
        from(ba in BankAccount,
          where:
            ba.id == ^bank_account_id and ba.balance - ^value >= 0 and ba.user_id == ^user_id,
          update: [set: [balance: ba.balance - ^value]]
        )
        |> repo.update_all([])

      {:ok, number}
    end)
    |> Multi.run(:back_operation, fn _repo, %{update_bank_account: update_bank_account} ->
      case update_bank_account do
        1 ->
          Registers.create_bank_operation(%{
            value: value,
            type: "withdraw",
            bank_account_id: bank_account_id
          })

        _ ->
          {:error, nil}
      end
    end)
    |> Multi.run(:send_email, fn _repo, %{back_operation: back_operation} ->
      ## Here will be the send of a email
      Logger.info(
        "Back Account Withdraw made #{back_operation.bank_account_id}: #{back_operation.value}"
      )

      {:ok, nil}
    end)
    |> Repo.transaction()
  end

  @doc """
  Transfer cash between bank_accounts.

  ## Examples

      iex> transfer_bank_account(%{value: value, bank_account_id: bank_account_id, bank_account_destiny_id: bank_account_destiny_id})
      {:ok, %{update_bank_account: 1, update_bank_account_destiny: 1, back_operation: back_operation}}

      iex> transfer_bank_account(%{value: value, bank_account_id: bank_account_id})
      {:error, _}

  """
  def transfer_bank_account(%{
        value: value,
        bank_account_id: bank_account_id,
        bank_account_destiny_id: bank_account_destiny_id,
        user_id: user_id
      }) do
    Multi.new()
    |> Multi.run(:update_bank_account, fn repo, _changes ->
      {number, nil} =
        from(ba in BankAccount,
          where:
            ba.id == ^bank_account_id and ba.balance - ^value >= 0 and ba.user_id == ^user_id,
          update: [set: [balance: ba.balance - ^value]]
        )
        |> repo.update_all([])

      {:ok, number}
    end)
    |> Multi.run(:update_bank_account_destiny, fn repo,
                                                  %{update_bank_account: update_bank_account} ->
      case update_bank_account do
        1 ->
          {number, nil} =
            from(ba in BankAccount,
              where: ba.id == ^bank_account_destiny_id,
              update: [set: [balance: ba.balance + ^value]]
            )
            |> repo.update_all([])

          {:ok, number}

        _ ->
          {:error, nil}
      end
    end)
    |> Multi.run(:back_operation, fn _repo,
                                     %{update_bank_account_destiny: update_bank_account_destiny} ->
      case update_bank_account_destiny do
        1 ->
          Registers.create_bank_operation(%{
            value: value,
            type: "transfer",
            bank_account_id: bank_account_id,
            bank_account_destiny_id: bank_account_destiny_id
          })

        _ ->
          {:error, nil}
      end
    end)
    |> Multi.run(:send_email, fn _repo, %{back_operation: back_operation} ->
      ## Here will be the send of a email
      Logger.info(
        "Back Account Trasfer made #{back_operation.bank_account_id} to #{
          back_operation.bank_account_destiny_id
        }: #{back_operation.value}"
      )

      {:ok, nil}
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
