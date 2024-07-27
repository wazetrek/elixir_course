defmodule InventoryManager do
  defstruct products: [], cart: []

  def add_product(%InventoryManager{products: products} = inventory, name, price, stock) do
    id = Enum.count(products) + 1
    product = %{id: id, name: name, price: price, stock: stock}
    IO.puts("Producto agregado: #{product.name}")
    %{inventory | products: products ++ [product]}
  end

  def list_products(%InventoryManager{products: products}) do
    if Enum.count(products) == 0 do
      IO.puts("No hay productos en el inventario")
    else
      puts_products_with_template(products)
    end
  end

  def increase_stock(%InventoryManager{products: products} = inventory, id, quantity) do
    case Enum.find(products, &(&1.id == id)) do
      nil ->
        IO.puts("El producto no existe")
        inventory
      %{} ->
        updated_products = Enum.map(products, fn product ->
          if product.id == id, do: %{product | stock: product.stock + quantity}, else: product
        end)
        %{inventory | products: updated_products}
    end
  end

  def sell_product(%InventoryManager{products: products, cart: cart} = inventory, id, quantity) do
    case Enum.find(products, &(&1.id == id)) do
      nil ->
        IO.puts("El producto no existe")
        inventory

      %{} = product when product.stock < quantity ->
        IO.puts("No hay suficiente stock")
        inventory

      %{} = product ->
        updated_products = Enum.map(products, fn product ->
          if product.id == id, do: %{product | stock: product.stock - quantity}, else: product
        end)
        updated_cart = cart ++ [%{id: product.id, quantity: quantity, unit_price: product.price}]
        %{inventory | products: updated_products, cart: updated_cart}
    end
  end

  def view_cart(%InventoryManager{cart: cart}) do
    if Enum.count(cart) == 0 do
      IO.puts("El carrito está vacío")
    else
      puts_cart_with_template(cart)
    end
  end

  def checkout(%InventoryManager{cart: cart} = inventory) do
    total = Enum.reduce(cart, 0, fn item, acc ->
      total_item = item.quantity * item.unit_price
      acc + total_item
    end)
    IO.puts("Total a pagar: $#{total}")
    IO.puts("Gracias por su compra")
    %{inventory | cart: []}
  end

  def run do
    inventory = %InventoryManager{}
    loop(inventory)
  end

  defp loop(inventory) do
    IO.puts("""
    \n
    Gestor de Inventario
    1. Agregar Producto
    2. Listar Productos
    3. Ingresar Stock Producto
    4. Vender Producto
    5. Visualizar Carrito
    6. Checkout
    7. Salir
    """)

    option = try do
        IO.write("Seleccione una opción: ")
        IO.gets("") |> String.trim() |> String.to_integer()
      rescue
        _ in ArgumentError ->
          IO.puts("Valor numérico no válido")
          nil
      end

    case option do
      1 ->
        IO.write("Ingrese el nombre del producto: ")
        name = IO.gets("") |> String.trim()
        IO.write("Ingrese el precio del producto: ")
        price = validate_integer()

        case validate_value(price) do
          {:ok, _price} ->
            IO.write("Ingrese el stock del producto: ")
            stock = validate_integer()

            case validate_value(stock) do
              {:ok, _stock} ->
                inventory = add_product(inventory, name, price, stock)
                loop(inventory)

              {:error, msg} ->
                IO.puts(msg)
                loop(inventory)
            end

          {:error, msg} ->
            IO.puts(msg)
            loop(inventory)
        end

      2 ->
        list_products(inventory)
        loop(inventory)

      3 ->
        IO.write("Ingrese el ID del producto: ")
        case validate_id() do
          nil ->
            loop(inventory)
          id ->
            IO.write("Ingrese la cantidad a ingresar: ")
            quantity = validate_integer()
            case validate_value(quantity) do
              {:ok, _quantity} ->
                inventory = increase_stock(inventory, id, quantity)
                loop(inventory)
              {:error, msg} ->
                IO.puts(msg)
                loop(inventory)
            end
        end

      4 ->
        IO.write("Ingrese el ID del producto: ")
        case validate_id() do
          nil ->
            loop(inventory)
          id ->
            IO.write("Ingrese la cantidad a vender: ")
            quantity = validate_integer()
            case validate_value(quantity) do
              {:ok, _quantity} ->
                inventory = sell_product(inventory, id, quantity)
                loop(inventory)
              {:error, msg} ->
                IO.puts(msg)
                loop(inventory)
            end
        end

      5 ->
        view_cart(inventory)
        loop(inventory)

      6 ->
        inventory = checkout(inventory)
        loop(inventory)

      7 ->
        IO.puts("Gracias por usar el Gestor de Inventario")

      _ ->
        IO.puts("Opción no válida")
        loop(inventory)
    end
  end

  defp validate_value(valor) when valor > 0, do: {:ok, valor}
  defp validate_value(_valor), do: {:error, "El valor debe ser mayor a cero"}

  defp validate_integer() do
    try do
      IO.gets("") |> String.trim() |> String.to_integer()
    rescue
      _ in ArgumentError ->
        0
    end
  end

  defp validate_id() do
    try do
      IO.gets("") |> String.trim() |> String.to_integer()
    rescue
      _ in ArgumentError ->
        IO.puts("ID no válido")
        nil
    end
  end

  defp puts_cart_with_template(cart) do
    IO.write("""
    | ================================= |
    |         Carrito de Compras        |
    |   ID. Cant x Precio   = Total     |
    """)
    total = Enum.reduce(cart, 0, fn item, acc ->
      total_item = item.quantity * item.unit_price
      IO.puts("| #{String.pad_leading(Integer.to_string(item.id), 4)}. #{String.pad_trailing(Integer.to_string(item.quantity), 4)} x $#{String.pad_trailing(Integer.to_string(item.unit_price), 7)} = $#{String.pad_trailing(Integer.to_string(total_item), 8)} |")
      acc + total_item
    end)
    IO.puts("| Total en carrito: $#{String.pad_trailing(Integer.to_string(total), 9)} #{String.pad_trailing("", 5)}|")
    IO.puts("| ================================= |")
  end

  defp puts_products_with_template(products) do
    IO.write("""
    | =============================================== |
    |                Lista de Productos               |
    |   ID. Nombre              Precio       Stock    |
    """)
    Enum.each(products, fn product ->
      puts_product(product)
    end)
    IO.puts("| =============================================== |")
  end

  defp puts_product(product) do
    IO.puts(
      "| #{String.pad_leading(Integer.to_string(product.id), 4)}. #{String.pad_trailing(String.slice(product.name, 0, 16), 16)}    $#{String.pad_trailing(Integer.to_string(product.price), 10)}  #{String.pad_trailing(Integer.to_string(product.stock), 6)}   |")
  end

end

InventoryManager.run()
