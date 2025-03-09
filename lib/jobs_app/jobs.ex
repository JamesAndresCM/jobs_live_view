defmodule JobsApp.Jobs do
  alias JobsApp.Repo
  alias JobsApp.Schema.Job
  import Ecto.Query

  @per_page 20

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

  def find_user_jobs(id, user_id) do
    Repo.get_by!(Job, %{id: id, user_id: user_id})
  end

  def list_jobs(page \\ 1) do
    offset = (page - 1) * @per_page

    query = from(job in Job, limit: @per_page, offset: ^offset, order_by: [desc: :inserted_at])
    Repo.all(query)
  end

  def list_jobs(page, user_id) do
    offset = (page - 1) * @per_page

    query =
      from(jobs in Job,
        where: jobs.user_id == ^user_id,
        limit: @per_page,
        offset: ^offset,
        order_by: [desc: :inserted_at]
      )

    Repo.all(query)
  end

  def list_new_jobs(%Job{} = last_inserted_job) do
    query =
      from(jobs in Job,
        where: jobs.inserted_at > ^last_inserted_job.inserted_at,
        order_by: [desc: :inserted_at]
      )

    Repo.all(query)
  end

  def list_new_jobs(nil) do
    []
  end
end
