defmodule LiveViewNativePdf.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias LiveViewNativePdf.Repo

  alias LiveViewNativePdf.Products.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products(params \\ []) do
    query = from(p in Product)

    params
    |> Enum.reduce(query, fn
      {:name, name}, query ->
        name = "%" <> name <> "%"
        where(query, [q], ilike(q.name, ^name))

      {:paginate, %{page: page, per_page: per_page}}, query ->
        from q in query, offset: ^((page - 1) * page), limit: ^per_page

      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        order_by(query, [q], [{^sort_order, ^sort_by}])
    end)
    |> Repo.all()
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def list_suggest_name(name) do
    name = "%" <> name <> "%"

    Product
    |> where([p], ilike(p.name, ^name))
    |> select([p], p.name)
    |> Repo.all()
  end
end
