require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should get show" do
    get task_url(@task)
    assert_response :success
  end

  test "should create task" do
    assert_difference("Task.count", 1) do
      post tasks_url, params: { task: { completed: false, title: "New task" } }
    end

    assert_redirected_to task_url(Task.order(:id).last)
  end

  test "should not create task with blank title" do
    assert_no_difference("Task.count") do
      post tasks_url, params: { task: { completed: false, title: " " } }
    end

    assert_response :unprocessable_entity
  end

  test "should update task" do
    patch task_url(@task), params: { task: { title: "Updated title" } }
    assert_redirected_to task_url(@task)
    assert_equal "Updated title", @task.reload.title
  end

  test "should toggle completion" do
    patch task_url(@task), params: { task: { completed: !@task.completed } }
    assert_redirected_to task_url(@task)
    assert_equal !tasks(:one).completed, @task.reload.completed
  end

  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete task_url(@task)
    end

    assert_redirected_to tasks_url
  end

  test "should update task via turbo stream" do
    patch task_url(@task), params: { task: { title: "Updated title" } }, as: :turbo_stream
    assert_response :success
    assert_match /turbo-stream action="replace" target="task_\d+"/, response.body
    assert_match /turbo-stream action="replace" target="task_counters"/, response.body
  end

  test "should destroy task via turbo stream" do
    assert_difference("Task.count", -1) do
      delete task_url(@task), as: :turbo_stream
    end
    assert_response :success
    assert_match /turbo-stream action="remove" target="task_\d+"/, response.body
    assert_match /turbo-stream action="replace" target="task_counters"/, response.body
  end
end