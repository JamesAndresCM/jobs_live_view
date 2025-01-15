defmodule JobsAppWeb.JobsLive do
  use JobsAppWeb, :live_view

  import JobsAppWeb.JobsLive.Components,
    only: [job_detail_modal: 1, job_form_modal: 1, job_row: 1]

  alias JobsApp.Schema.Job
  alias JobsApp.Jobs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, paginate_jobs(socket, 1)}
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
    case Jobs.insert_or_update_job(socket.assigns.job, params) do
      {:ok, job} ->
        socket = stream_insert(socket, :jobs, job, at: 0)

        {:noreply,
         socket
         |> put_flash(:info, "job created: #{job.title}")
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

  @impl true
  def handle_event("next-page", _params, socket) do
    new_page = socket.assigns.page + 1
    {:noreply, paginate_jobs(socket, new_page)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <.button phx-click={JS.patch(%JS{}, ~p"/new") |> show_modal("job-form-modal")}>
        <%= gettext("Publicar") %>
      </.button>
      <div id="jobs" phx-update="stream" phx-viewport-bottom={!@end_of_timeline? && "next-page"}>
        <.job_row :for={{dom_id, job} <- @streams.jobs} id={dom_id} job={job} />
      </div>
      <div :if={@end_of_timeline?} class="mt-5 text-center">
        🎉 <%= gettext("no existen mas registros") %> 🎉
      </div>
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

  defp paginate_jobs(socket, new_page) do
    jobs = Jobs.list_jobs(new_page)

    if Enum.empty?(jobs) do
      assign(socket, end_of_timeline?: true)
    else
      socket
      |> assign(end_of_timeline?: false)
      |> assign(page: new_page)
      |> stream(:jobs, jobs)
    end
  end
end
