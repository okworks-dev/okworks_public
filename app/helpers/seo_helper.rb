module SeoHelper
  def jobs_index_title(params, detail = false)   
    title = ""

    if params[:q] && params[:q][:title_or_detail_cont].present?
      title = title.blank? ? params[:q][:title_or_detail_cont] : "#{title} × #{params[:q][:title_or_detail_cont]}"
    end

    if params[:q] && params[:q][:job_type_id_eq].present?
      job_type = JobType.find_by(id: params[:q][:job_type_id_eq])
      title = title.blank? ? job_type.name : "#{title} × #{job_type.name}"
    end

    if params[:q] && params[:q][:skills_id_eq].present?
      skill = Skill.find_by(id: params[:q][:skills_id_eq])
      title = title.blank? ? skill.name : "#{title} × #{skill.name}"
    end

    if detail && params[:desired_number_of_days].present?
      desired_days = "稼働#{params[:desired_number_of_days]}日"
      title = title.blank? ? desired_days : "#{title} × #{desired_days}"
    end

    title.blank? ? '新着IT系フリーランス案件・求人' : "#{title}のIT系フリーランス案件・求人"
  end

  def jobs_index_description(params)
    "#{jobs_index_title(params, true)} | #{default_meta_tags[:description]}"
  end
end
