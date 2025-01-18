defmodule JobsAppWeb.JobsLive do
  use JobsAppWeb, :live_view

  import JobsAppWeb.JobsLive.Components,
    only: [job_detail_modal: 1, job_form_modal: 1, job_row: 1]

  alias JobsApp.Schema.Job
  alias JobsApp.Jobs

  @impl true
  def mount(params, _session, socket) do
    page = Map.get(params, "page", 1)
    page_size = Map.get(params, "page_size", 10)

    %{entries: jobs, total_pages: total_pages, page_number: page_number} =
      Jobs.list_jobs(%{"page" => page, "page_size" => page_size})

    socket =
      socket
      |> assign(:total_pages, total_pages)
      |> assign(:current_page, page_number)
      |> stream(:jobs, jobs)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = apply_action(socket.assigns.live_action, params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"job" => params}, socket) do
    changeset =
      socket.assigns.job
      |> Job.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"job" => params}, socket) do
    action = socket.assigns.live_action |> Atom.to_string
    case Jobs.insert_or_update_job(socket.assigns.job, params) do
      {:ok, job} ->
        socket = stream_insert(socket, :jobs, job, at: 0)

        {:noreply,
         socket
         |> put_flash(:info, "job #{action}: #{job.title}")
         |> push_patch(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Jobs.find_job(id)
    |> Jobs.delete_job()
    |> case do
      {:ok, job} ->
        socket = stream_delete(socket, :jobs, job)

        {:noreply,
         socket
         |> put_flash(:info, "Job eliminado: #{job.title}")
         |> push_patch(to: ~p"/")}

      {:error, _error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Job no pudo eliminarse: #{socket.assigns.job.title}")}
    end
  end


  def handle_event("paginate", %{"page" => page}, socket) do
    page = String.to_integer(page)

    %{entries: jobs, total_pages: total_pages, page_number: page_number} =
      Jobs.list_jobs(%{"page" => page, "page_size" => 10})

    socket =
      socket
      |> assign(:total_pages, total_pages)
      |> assign(:current_page, page_number)
      |> stream(:jobs, jobs, reset: true)

    {:noreply, socket}
  end
  @impl true
  def render(assigns) do
  ~H"""
  <div class="space-y-8">
    <.button phx-click={JS.patch(%JS{}, ~p"/new") |> show_modal("job-form-modal")}>
      <%= gettext("Publicar") %>
    </.button>
    <div id="jobs" class="w-full max-w-screen-lg mx-auto">
      <table class="card-body table w-full border-collapse">
        <thead>
          <tr class="bg-gray-200">
            <th class="border border-gray-300 px-4 py-2 text-left font-bold">Id</th>
            <th class="border border-gray-300 px-4 py-2 text-left font-bold">Title</th>
            <th class="border border-gray-300 px-4 py-2 text-left font-bold">Options</th>
          </tr>
        </thead>
        <tbody id="job-rows" phx-update="stream">
          <.job_row :for={{dom_id, job} <- @streams.jobs} id={dom_id} job={job} />
        </tbody>
      </table>
    </div>
  </div>
  <div class="pagination mt-4 flex justify-between items-center">
    <button
      :if={@current_page > 1}
      phx-click="paginate"
      phx-value-page={@current_page - 1}
      class="px-4 py-2 text-white bg-blue-600 hover:bg-blue-700 rounded-full transition-colors duration-200"
    >
      Anterior
    </button>

    <span class="text-sm font-medium">Página <%= @current_page %> de <%= @total_pages %></span>

    <button
      :if={@current_page < @total_pages}
      phx-click="paginate"
      phx-value-page={@current_page + 1}
      class="px-4 py-2 text-white bg-blue-600 hover:bg-blue-700 rounded-full transition-colors duration-200"
    >
      Siguiente
    </button>
  </div>
  <.job_form_modal :if={@live_action in [:new, :edit]} changeset={@changeset} job={@job} />
  <.job_detail_modal :if={@live_action == :show} job={@job} />
  """
end


  defp apply_action(:index, _params, socket) do
    assign(socket, changeset: nil, job: nil)
  end

  defp apply_action(:new, _params, socket) do
    job = %Job{}
    changeset = Job.changeset(job)

    assign(socket, changeset: changeset, job: job)
  end

  defp apply_action(:edit, %{"id" => id}, socket) do
    job = Jobs.find_job(id)
    changeset = Job.changeset(job)

    assign(socket, changeset: changeset, job: job)
  end

  defp apply_action(:show, %{"id" => id}, socket) do
    job = Jobs.find_job(id)

    assign(socket, job: job)
  end
end
