defmodule TaskManager do
  defstruct tasks: []

  def add_task(%TaskManager{tasks: tasks} = task_manager, description) do
    id = Enum.count(tasks) + 1
    task = %{id: id, description: description, completed: false}
    %{task_manager | tasks: tasks ++ [task]}
  end

  def list_tasks(%TaskManager{tasks: tasks}) do
    Enum.each(tasks, fn task ->
      IO.puts("#{task.id}. #{task.description} [#{if task.completed, do: "Completada", else: "Pendiente"}]")
    end)
  end

  def complete_task(%TaskManager{tasks: tasks} = task_manager, id) do
    updated_tasks = Enum.map(tasks, fn task ->
      if task.id == id do
        %{task | completed: true}
      else
        task
      end
    end)
    %{task_manager | tasks: updated_tasks}
  end

  def run do
    task_manager = %TaskManager{}
    loop(task_manager)
  end

  defp loop(task_manager) do
    IO.puts("""
    Gestor de Tareas
    1. Agregar Tarea
    2. Listar Tareas
    3. Completar Tarea
    4. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese la descripción de la tarea: ")
        description = IO.gets("") |> String.trim()
        task_manager = add_task(task_manager, description)
        loop(task_manager)

      2 ->
        list_tasks(task_manager)
        loop(task_manager)

      3 ->
        IO.write("Ingrese el ID de la tarea a completar: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        task_manager = complete_task(task_manager, id)
        loop(task_manager)

      4 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(task_manager)
    end
  end
end

# Ejecutar el gestor de tareas
TaskManager.run()
