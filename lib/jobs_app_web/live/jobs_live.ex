defmodule JobsAppWeb.JobsLive do
  use JobsAppWeb, :live_view

  import JobsAppWeb.JobsLive.Components,
    only: [job_detail_modal: 1, job_row: 1]

  alias JobsApp.Jobs
  alias Phoenix.PubSub
  @pub_sub_topic "new_jobs"

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(JobsApp.PubSub, @pub_sub_topic)

    page = 1
    Task.async(fn -> paginate_jobs(page) end)

    socket =
      socket
      |> assign(refresh_jobs: false, loading_jobs: true, page: page, end_of_timeline?: false)
      |> stream(:jobs, [])

    {:ok, socket}
  end

  @impl true
  def handle_info({:new_jobs}, socket) do
    {:noreply, assign(socket, refresh_jobs: true)}
  end

  @impl true
  def handle_info({ref, jobs}, socket) do
    last_job_inserted = if socket.assigns.page == 1, do: List.first(jobs)

    socket =
      if Enum.empty?(jobs) do
        socket
        |> assign(end_of_timeline?: true)
        |> stream(:jobs, [])
        |> assign_new(:last_job_inserted, fn -> last_job_inserted end)
      else
        socket
        |> assign(end_of_timeline?: false)
        |> stream(:jobs, jobs)
        |> assign_new(:last_job_inserted, fn -> last_job_inserted end)
      end

    Process.demonitor(ref)

    {:noreply, assign(socket, loading_jobs: false)}
  end

  @impl true
  def handle_info({:DOWN, _ref, _process, _pid, _reason}, socket) do
    IO.inspect("Finish")
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = apply_action(socket.assigns.live_action, params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("next-page", _params, socket) do
    page = socket.assigns.page + 1
    Task.async(fn -> paginate_jobs(page) end)
    {:noreply, assign(socket, loading_jobs: true, page: page)}
  end

  @impl true
  def handle_event("refresh_jobs", _params, socket) do
    new_jobs =
      socket.assigns.last_job_inserted
      |> Jobs.list_new_jobs()
      |> Enum.reverse()

    socket =
      socket
      |> assign(refresh_jobs: false)
      |> stream(:jobs, new_jobs, at: 0)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-8">
      <.button
        :if={@current_user}
        phx-click={JS.patch(%JS{}, ~p"/new") |> show_modal("job-form-modal")}
      >
        <%= gettext("Publicar") %>
      </.button>

      <div class="sticky top-0 underline">
        <.link :if={@refresh_jobs} href="#top-page" phx-click="refresh_jobs">
          <%= gettext("nuevos jobs publicados") %>
        </.link>
      </div>

      <div id="jobs" phx-update="stream" phx-viewport-bottom={!@end_of_timeline? && "next-page"}>
        <.job_row :for={{dom_id, job} <- @streams.jobs} id={dom_id} job={job} />
      </div>

      <div :if={@loading_jobs && !@end_of_timeline?} class="text-center">
        <%= gettext("Cargando...") %>
      </div>

      <div :if={@end_of_timeline?} class="mt-5 text-center">
        🎉 <%= gettext("no existen mas registros") %> 🎉
      </div>
    </div>
    <.job_detail_modal :if={@live_action == :show} job={@job} />
    """
  end

  defp apply_action(:index, _params, socket) do
    socket
  end

  defp apply_action(:show, %{"id" => id}, socket) do
    job = Jobs.find_job(id)

    assign(socket, job: job)
  end

  defp paginate_jobs(page) do
    :timer.sleep(3000)
    Jobs.list_jobs(page)
  end
end
