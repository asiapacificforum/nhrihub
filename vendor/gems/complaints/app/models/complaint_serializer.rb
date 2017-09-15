module ComplaintSerializer
  def self.to_json

    sql = <<-SQL
      select complaints.*,
             (#{notes_sql}) notes,
             (#{assigns_sql}) assigns,
             (#{attached_documents_sql}) attached_documents,
             (#{good_governance_complaint_basis_ids_sql}) good_governance_complaint_basis_ids,
             (#{special_investigations_unit_complaint_basis_ids_sql}) special_investigations_unit_complaint_basis_ids,
             (#{human_rights_complaint_basis_ids_sql}) human_rights_complaint_basis_ids,
             (#{current_assignee_id_sql}) current_assignee_id
     from complaints
    SQL
    res = ActiveRecord::Base.connection.execute(sql)
    res.map do |rr|
      # b/c postgres produces json for association arrays
      rr["notes"] = JSON.parse(rr["notes"] || "[]")
      rr["assigns"] = JSON.parse(rr["assigns"] || "[]")
      rr["attached_documents"] = JSON.parse(rr["attached_documents"] || "[]")
      rr["good_governance_complaint_basis_ids"] = JSON.parse(rr["good_governance_complaint_basis_ids"] || "[]").map{|ggid| ggid["id"]}
      rr["special_investigations_unit_complaint_basis_ids"] = JSON.parse(rr["special_investigations_unit_complaint_basis_ids"] || "[]").map{|ggid| ggid["id"]}
      rr["human_rights_complaint_basis_ids"] = JSON.parse(rr["human_rights_complaint_basis_ids"] || "[]").map{|ggid| ggid["id"]}
      rr
    end
  end

  def self.current_assignee_id_sql
    <<-SQL
      select users.id
      from users
        join assigns
          on assigns.user_id = users.id
        and assigns.id = (select max(id) from assigns where assigns.complaint_id = complaints.id)
    SQL
  end


  def self.special_investigations_unit_complaint_basis_ids_sql
    complaint_basis_ids_sql("Siu::ComplaintBasis", "SpecialInvestigationsUnit")
  end

  def self.human_rights_complaint_basis_ids_sql
    <<-SQL
      select array_to_json(array_agg(row_to_json(gg)))
      from ( select conventions.id
                               from complaint_complaint_bases
                               join conventions
                                 on complaint_complaint_bases.complaint_basis_id = conventions.id
                               where
                                 complaint_complaint_bases.type = 'ComplaintHumanRightsComplaintBasis' and
                                 complaint_complaint_bases.complaint_id = complaints.id ) gg
    SQL
  end

  def self.good_governance_complaint_basis_ids_sql
    complaint_basis_ids_sql("GoodGovernance::ComplaintBasis","GoodGovernance")
  end

  def self.complaint_basis_ids_sql(cb_type,ccb_type)
    <<-SQL
      select array_to_json(array_agg(row_to_json(gg)))
      from ( select complaint_bases.id
                               from complaint_complaint_bases
                               join complaint_bases
                                 on complaint_complaint_bases.complaint_basis_id = complaint_bases.id
                               where
                                 complaint_complaint_bases.type = 'Complaint#{ccb_type}ComplaintBasis' and
                                 complaint_bases.type = '#{cb_type}' and
                                 complaint_complaint_bases.complaint_id = complaints.id ) gg
    SQL
  end

  def self.attached_documents_sql
    url = Rails.application.routes.url_helpers.complaint_document_path(I18n.locale, 'id')
    <<-SQL
      select array_to_json(array_agg(row_to_json(dd)))
      from (select complaint_id, file_id, filename, filesize, id, "lastModifiedDate", original_type, (select '#{ComplaintDocument.serialization_key}')  serialization_key, title, (select replace('#{url}','id',cast(id as varchar))) url, user_id
            from complaint_documents where complaint_documents.complaint_id = complaints.id) dd
    SQL
  end

  def self.assigns_sql
    <<-SQL
      select array_to_json(array_agg(row_to_json(aa)))
      from (select to_char(created_at, 'Mon FMDD, YYYY') as date,
                   (select concat("firstName", ' ', "lastName")
                    from users
                    where users.id = assigns.user_id) as name
            from assigns
            where assigns.complaint_id = complaints.id
            order by created_at) aa
    SQL
  end

  def self.notes_sql
    author_name = %Q{(select concat("firstName", ' ', "lastName") from users where users.id = notes.author_id) author_name}
    editor_name = %Q{(select concat("firstName", ' ', "lastName") from users where users.id = notes.editor_id) editor_name}
    url = %Q{(select concat('/#{I18n.locale}/complaints/', complaints.id, '/notes/', notes.id)) url} #/:locale/complaints/:complaint_id/notes/:id
    date = %Q{(select to_char(created_at, 'Mon FMDD, YYYY')) date}
    updated_on = %Q{(select to_char(updated_at, 'Mon FMDD, YYYY')) updated_on}
    notes_sql = <<-SQL
      select array_to_json(array_agg(row_to_json(nn)))
      from (select notes.*, #{author_name}, #{editor_name}, #{url}, #{date}, #{updated_on} from notes where notes.notable_id = complaints.id) nn
    SQL
  end
end
