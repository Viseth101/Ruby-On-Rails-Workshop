class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = Task.order(created_at: :desc)
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      redirect_to @task, notice: "Task created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html do
          if turbo_frame_request?
            render partial: "tasks/task", locals: { task: @task }
          else
            redirect_to @task, notice: "Task updated."
          end
        end
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@task, partial: "tasks/task", locals: { task: @task }),
            turbo_stream.replace("task_counters", partial: "tasks/counters")
          ]
        end
      else
        format.html do
          if turbo_frame_request?
            render partial: "tasks/task", locals: { task: @task }, status: :unprocessable_entity
          else
            render :edit, status: :unprocessable_entity
          end
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@task, partial: "tasks/task", locals: { task: @task }), status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @task.destroy!
    respond_to do |format|
      # Turbo Stream can target this destroyed record by dom_id (for example "task_3").
      format.turbo_stream
      format.html { redirect_to tasks_path, notice: "Task deleted." }
    end
  end

  private

  def set_task
    # Route param :id is used to load one Task record from the tasks table.
    @task = Task.find(params.expect(:id))
  end

  def task_params
    # form_with model: task submits task[title] and task[completed]; this whitelists them.
    params.expect(task: %i[title completed])
  end
end
