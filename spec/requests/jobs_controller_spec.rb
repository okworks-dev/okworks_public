require "rails_helper"

describe JobsController, :type => :request do
  before do
    created_jobs = create_list(:job, 25)
    @job = created_jobs.first
  end

  describe 'GET index' do
    it "リクエストが成功すること" do
      get jobs_path
      expect(response.status).to eq(200)
    end
  end

  describe 'GET index with conditions' do
    it "リクエストが成功すること" do
      get jobs_path, params: {"utf8"=>"✓", "q"=>{"title_or_detail_cont"=>"", "skills_id_eq"=>"", "job_type_id_eq"=>"1", "average_reward_gteq"=>""}, "desired_number_of_days"=>""}
      expect(response.status).to eq(200)
    end
  end

  describe 'GET show' do
    it "リクエストが成功すること" do
      get job_path(@job)
      expect(response.status).to eq(200)
    end
  end
end