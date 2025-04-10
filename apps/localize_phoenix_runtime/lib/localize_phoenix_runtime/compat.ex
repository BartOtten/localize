defmodule Localize.PhoenixRuntime.Compat do
  @moduledoc """
  Compatibility functions
  """
  @doc """
  Returns the module to use for LiveView assignments
  """
  @spec assign_module :: module()
  {:ok, phx_version} = :application.get_key(:phoenix, :vsn)

  if phx_version |> to_string() |> Version.match?("< 1.7.0-dev") do
    def assign_module, do: Phoenix.LiveView
  else
    def assign_module, do: Phoenix.Component
  end
end
