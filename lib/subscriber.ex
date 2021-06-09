defmodule Subscriber do
  @moduledoc """
  Write and read subscribers.txt file.
  """

  @subscribers_file_name %{:prepago => "pre.txt", :pospago => "pos.txt"}

  defstruct name: nil, number: nil, cpf: nil, plan: nil

  @spec register(String.t(), String.t(), String.t(), String.t()) ::
          {:error, String.t()} | {:ok, String.t()}
  @doc """
  Inserts a subscriber into the file.
  """
  def register(name, number, cpf, plan) do
    if subscriber_exists?(number) do
      {:error, "There is already a subscriber with this number!"}
    else
      subscriber = %__MODULE__{
        name: name,
        number: number,
        cpf: cpf,
        plan: plan
      }

      merge_subscriber_with_file_content(subscriber, plan)
    end
  end

  @spec prepago_subscribers :: [
          %Subscriber{cpf: String.t(), name: String.t(), number: String.t(), plan: String.t()}
        ]
  @doc """
  Returns the pre.txt file content.
  """
  def prepago_subscribers(), do: file_content(:prepago)

  @spec pospago_subscribers :: [
          %Subscriber{cpf: String.t(), name: String.t(), number: String.t(), plan: String.t()}
        ]
  @doc """
  Returns the pos.txt file content.
  """
  def pospago_subscribers(), do: file_content(:pospago)

  @spec subscribers :: [
          %Subscriber{cpf: String.t(), name: String.t(), number: String.t(), plan: String.t()}
        ]
  @doc """
  Returns the pos.txt plus pre.txt file content.
  """
  def subscribers(), do: file_content(:pospago) ++ file_content(:prepago)

  @spec file_content(:all | :pospago | :prepago) ::
          [%Subscriber{cpf: String.t(), name: String.t(), number: String.t(), plan: String.t()}]
          | []
  @doc """
  Returns a list with file content.
  """
  def file_content(plan) do
    case File.read(@subscribers_file_name[plan]) do
      {:ok, subscribers_binary} -> :erlang.binary_to_term(subscribers_binary)
      {:error, _reason} -> []
    end
  end

  @spec search_subscriber(integer, :all | :pospago | :prepago) :: %Subscriber{} | nil
  @doc """
  Search subscriber by specific file.
  """
  def search_subscriber(number, where \\ :all) do
    case where do
      :all -> filter_subscriber(subscribers(), number)
      :prepago -> filter_subscriber(prepago_subscribers(), number)
      :pospago -> filter_subscriber(pospago_subscribers(), number)
    end
  end

  defp merge_subscriber_with_file_content(
         %{name: name, number: number} = subscriber,
         plan_file_name
       ) do
    (file_content(plan_file_name) ++ [subscriber])
    |> :erlang.term_to_binary()
    |> write_in_the_file(plan_file_name)

    {:ok, "Assinante #{name} com o número #{number} cadastrado com sucesso!"}
  end

  defp filter_subscriber(subscribers_list, number) do
    Enum.find(subscribers_list, &(&1.number == number))
  end

  defp subscriber_exists?(number) do
    Enum.find_value(subscribers(), fn subscriber -> subscriber.number == number end)
  end

  defp write_in_the_file(subscribers_list, plan) do
    File.write!(@subscribers_file_name[plan], subscribers_list)
  end
end
