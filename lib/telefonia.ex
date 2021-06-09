defmodule Telefonia do
  @moduledoc """
  Documentation for `Telefonia`.
  """

  @spec register_subscriber(String.t(), String.t(), String.t(), String.t()) ::
          {:error, String.t()} | {:ok, String.t()}
  @doc """
  Write the subscriber in the pos.txt file or pre.txt file.
  """
  defdelegate register_subscriber(name, number, cpf, plan),
    to: Subscriber,
    as: :register
end
