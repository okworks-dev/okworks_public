class JobsController < ApplicationController
  PER = 20
  before_action :set_select_box, only: :index

  def index
    @jobs, @q = Job.search_jobs(search_params, params[:desired_number_of_days])
    @jobs = @jobs.page(params[:page]).per(PER)
  end

  def show
    job_id = params[:id]
    @job = Job.find_by(id: job_id)    
    @related_jobs = @job.related_jobs
  end

private
  def search_params
    if params[:q]
      params.require(:q).permit(:title_or_detail_cont, :skills_id_eq, :job_type_id_eq, :average_reward_gteq)
    else
      params
    end
  end
end
