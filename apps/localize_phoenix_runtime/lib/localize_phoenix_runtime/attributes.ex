defmodule Localize.PhoenixRuntime.Attrs do
  @moduledoc """
  Provides an interface to access and update Localize attributes
  in sockets, or connections (hereinafter `containers`).
  """

  @type container :: Phoenix.Socket.t() | Phoenix.LiveView.Socket.t() | Plug.Conn.t()
  @type key :: atom()
  @type value :: any()
  @type attrs_fun :: (map() -> Enumerable.t())
  @type update_fun :: (value() -> value())
  @type t :: %{optional(key) => value}

  @doc """
  Returns true if the given key or attribute tuple represents a private attribute.

  A private attribute is one whose name starts with `"__"`.
  """
  @spec private?({atom(), any()} | atom()) :: boolean()
  def private?({key, _v}), do: private?(key)

  def private?(key) when is_atom(key) do
    key |> Atom.to_string() |> String.starts_with?("__")
  end

  @doc """
  Updates the container's attributes by applying the given function.

  The function receives the current attributes map and must return an enumerable,
  which is then converted into a new map.
  """
  @spec update(container(), attrs_fun()) :: container()
  def update(sock_or_conn, fun) when is_function(fun, 1) do
    current = get(sock_or_conn)
    new = current |> fun.() |> Enum.into(%{})
    put(sock_or_conn, new)
  end

  @doc """
  Updates the value assigned to `key` in the container's attributes by applying the given function.
  """
  @spec update(container(), key(), update_fun()) :: container()
  def update(sock_or_conn, key, fun) when is_function(fun, 1) do
    current = get(sock_or_conn, key)
    new = fun.(current)
    put(sock_or_conn, key, new)
  end

  @doc """
  Merges the given value into the container's attributes.

  The value can be either a list of key-value pairs or a map.
  """
  @spec merge(container(), keyword() | map()) :: container()
  def merge(sock_or_conn, value) when is_list(value) do
    merge(sock_or_conn, Map.new(value))
  end

  def merge(sock_or_conn, value) when is_map(value) do
    Enum.reduce(value, sock_or_conn, fn {k, v}, acc ->
      put(acc, k, v)
    end)
  end

  @doc """
  Replaces the container's attributes with the provided map.
  """
  @spec put(container(), map()) :: container()
  def put(sock_or_conn, value) when is_map(value) do
    sock_or_conn
    |> ensure_localized()
    |> put_in([Access.key!(:private), :loc], value)
  end

  @doc """
  Assigns `value` to `key` in the container's attributes.
  """
  @spec put(container(), key(), value()) :: container()
  def put(sock_or_conn, key, value) when is_atom(key) do
    sock_or_conn
    |> ensure_localized()
    |> update_in([Access.key!(:private), :loc], &Map.put(&1, key, value))
  end

  @doc """
  Retrieves the value for `key` from the container's attributes, or returns `default`.

  When no key is provided, returns the entire attributes map.
  """
  @spec get(container(), key() | nil, value() | map()) :: value() | map()
  def get(sock_or_conn, key \\ nil, default \\ nil)

  def get(sock_or_conn, nil, default) do
    case sock_or_conn.private do
      %{loc: attrs} -> attrs
      _other -> default || %{}
    end
  end

  def get(sock_or_conn, key, default) when is_atom(key) do
    case sock_or_conn.private do
      %{loc: attrs} -> Map.get(attrs, key, default)
      _other -> default
    end
  end

  @doc """
  Retrieves the value for `key` from the container's attributes.

  Raises an error (with an optional custom message) if the key is not found.
  """
  @spec get!(container(), key(), String.t() | nil) :: value() | no_return()
  def get!(sock_or_conn, key, error_msg \\ nil) when is_atom(key) do
    attrs =
      case sock_or_conn.private do
        %{loc: attrs} -> attrs
        _other -> %{}
      end

    case Map.fetch(attrs, key) do
      {:ok, value} ->
        value

      :error ->
        msg =
          error_msg ||
            "Key #{inspect(key)} not found in #{inspect(attrs)}"

        raise(msg)
    end
  end

  # Ensures that the container has a :loc key in its :private map.
  @spec ensure_localized(container()) :: container()
  defp ensure_localized(%{private: %{}} = sock_or_conn) do
    update_in(sock_or_conn, [Access.key(:private, %{})], fn private ->
      Map.put_new(private, :loc, %{})
    end)
  end

  defp ensure_localized(%{private: nil} = sock_or_conn) do
    sock_or_conn
    |> Map.put(:private, %{})
    |> ensure_localized()
  end
end
