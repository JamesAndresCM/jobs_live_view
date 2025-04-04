# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     JobsApp.Repo.insert!(%JobsApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias JobsApp.Users
alias JobsApp.Schema.Job
alias JobsApp.Jobs

# Create a user
{:ok, user} = Users.save_user(%{"email" =>"jhondoe@domain.com"})

Enum.each(1..50, fn index ->
  :timer.sleep(1000)
  {:ok, _job} = Jobs.insert_or_update_job(%Job{user_id: user.id}, %{"title" => "Job #{index}"})
end)