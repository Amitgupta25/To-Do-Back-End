class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :destroy]

  def index
    @tasks = Task.all
		render json: { count: @tasks.count, tasks: @tasks }, status: :ok
  end

  def show
		render json: @task, status: :ok
  end

  def create
		total_tasks_count = Task.count
		todo_tasks_count = Task.where(status: 0).count
	
		if todo_tasks_count > total_tasks_count * 0.5
			render json: { error: "Cannot create new task. More than 50% of tasks are already in '0' status." }, status: :unprocessable_entity
			return
		end
	
		@task = Task.new(task_params)
	
		if @task.status != 0
			render json: { error: "Status must be '0' when creating a new task." }, status: :unprocessable_entity
			return
		end
	
		if @task.save
			render json: @task, status: :created
		else
			render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
		end
	end
	

  def update
    if @task.update(task_params)
			render json: @task, status: :ok
    else
			render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
		render json: { message: 'Task destroyed successfully' }, status: :ok
  end

	def filter_by_status
		if params[:statuses].present?
			if params[:statuses] == "All"
				@tasks = Task.all
			else
				statuses = params[:statuses].split(',').map(&:strip)
				@tasks = Task.where(status: statuses)
			end
			render json: @tasks, status: :ok
		else
			render json: { error: 'Statuses parameter is missing' }, status: :unprocessable_entity
		end
	end
	
	
	

  private

  def set_task
    @task = Task.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
    render json: { error: 'Task not found' }, status: :not_found
  end

  def task_params
    params.require(:task).permit(:title, :description, :status)
  end
end
