defmodule Library do
  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def list_books(library) do
    if Enum.count(library) == 0 do
      IO.puts("No hay libros en la librería")
    else
      pad = 35
      IO.puts("-------------------- Libros -------------------")
      Enum.filter(library, fn book -> book.available end)
      |> Enum.each(fn book ->
        IO.write("""
        |#{String.pad_leading("Título:", 8)} #{String.pad_trailing(String.slice(book.title, 0, pad), pad)} |
        |#{String.pad_leading("Autor:", 8)} #{String.pad_trailing(book.author, pad)} |
        |#{String.pad_leading("ISBN:", 8)} #{String.pad_trailing(book.isbn, pad)} |
        |#{String.pad_leading("Disp:", 8)} #{String.pad_trailing(book.available && "Sí" || "No", pad)} |
        -----------------------------------------------
        """)
      end)
    end
  end

  def find_book(library, isbn) do
    if is_integer(isbn), do: isbn = Integer.to_string(isbn)

    book = Enum.find(library, &(&1.isbn == isbn))
    if book do
      IO.puts("El libro #{book.title} está #{book.available && "disponible" || "prestado"}")
    else
      IO.puts("Libro no encontrado")
    end
  end

  def list_users(users) do
    if Enum.count(users) == 0 do
      IO.puts("No hay usuarios en la librería")
    else
      pad = 30
      IO.puts("----------------- Usuarios ---------------")
      Enum.each(users, fn user ->
        IO.write("""
        |#{String.pad_leading("Nombre:", 8)} #{String.pad_trailing(String.slice(user.name, 0, pad), pad)} |
        |#{String.pad_leading("ID:", 8)} #{String.pad_trailing(user.id, pad)} |
        ------------------------------------------
        """)
      end)
    end
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end

  def run do
    library = [
      %Book{title: "El principito", author: "Antoine de Saint-Exupéry", isbn: "978-987-612-778-5", available: true},
      %Book{title: "Trilogía Fundación", author: "Isaac Asimov", isbn: "978-84-9908-320-9", available: true},
      %Book{title: "Cronicas de dune", author: "Frank Herbert", isbn: "978-84-9759-682-4", available: true},
      %Book{title: "Viaje al centro de la Tierra", author: "Julio Verne", isbn: "978-84-670-5066-0", available: false},
      %Book{title: "La vuelta al mundo en 80 días", author: "Julio Verne", isbn: "978-84-08-27087-4", available: true}
    ]
    users = [
      %User{name: "Juan Armando Casas Contreras", id: "1", borrowed_books: []},
      %User{name: "María Antonieta de las nieves", id: "2", borrowed_books: []}
    ]
    loop(library, users)
  end

  def loop(library, users) do
    IO.puts("""
    Bienvenido a la librería
    1. Agregar libro
    2. Listar libros disponibles
    3. Verificar disponibilidad de libro
    ----------------------------------
    4. Agregar usuario
    5. Listar usuarios
    ----------------------------------
    6. Prestar libro
    7. Devolver libro
    8. Ver libros prestados por usuario
    ----------------------------------
    9. Salir
    """)

    option = try do
      IO.write("Seleccione una opción: ")
      IO.gets("") |> String.trim() |> String.to_integer()
    rescue
      _ in ArgumentError ->
        IO.puts("Valor numérico no válido")
        nil
    end
    process_option(option, library, users)
  end

  def process_option(option, library, users) do
    case option do
      1 ->
        IO.write("Ingrese el título del libro: ")
        title = IO.gets("") |> String.trim()
        IO.write("Ingrese el autor del libro: ")
        author = IO.gets("") |> String.trim()
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim()

        book = %Book{title: title, author: author, isbn: isbn}
        loop(add_book(library, book), users)
      2 ->
        list_books(library)
        loop(library, users)
      3 ->
        IO.write("Ingrese el ISBN del libro: ")
        isbn = IO.gets("") |> String.trim()

        loop(find_book(library, isbn), users)
      4 ->
        IO.write("Ingrese el nombre del usuario: ")
        name = IO.gets("") |> String.trim()
        IO.write("Ingrese el ID del usuario: ")
        id = IO.gets("") |> String.trim()

        user = %User{name: name, id: id}
        loop(library, add_user(users, user))
      5 ->
        list_users(users)
        loop(library, users)
      9 ->
        IO.puts("Saliendo...")
      _ ->
        IO.puts("Opción no válida")
        loop(library, users)
    end
  end
end

Library.run()
