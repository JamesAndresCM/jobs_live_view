defmodule JobsApp.Jobs do
  alias JobsApp.Repo
  alias JobsApp.Schema.Job
  import Ecto.Query

  def create_job(attr) do
    %Job{}
    |> Job.changeset(attr)
    |> Repo.insert()
  end

  def update_job(%Job{} = job, attr) do
    job |> Job.changeset(attr) |> Repo.update()
  end

  def insert_or_update_job(%Job{} = job, attr) do
    job |> Job.changeset(attr) |> Repo.insert_or_update()
  end

  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  def find_job(id) do
    Repo.get!(Job, id)
  end

  def list_jobs(params \\ %{}) do
    query = from(job in Job, order_by: [desc: :inserted_at])
    Repo.paginate(query, params)
  end
end
