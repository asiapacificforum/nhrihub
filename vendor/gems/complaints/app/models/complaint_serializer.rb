class ComplaintSerializer
  class << self
    def to_json

      sql = <<-SQL
      select complaints.*,
             (#{notes}) notes,
             (#{assigns}) assigns,
             (#{attached_documents}) attached_documents,
             (#{good_governance_complaint_basis_ids}) good_governance_complaint_basis_ids,
             (#{special_investigations_unit_complaint_basis_ids}) special_investigations_unit_complaint_basis_ids,
             (#{human_rights_complaint_basis_ids}) human_rights_complaint_basis_ids,
             (#{current_assignee_id}) current_assignee_id,
             (#{current_assignee_name}) current_assignee_name,
             (#{current_status_humanized}) current_status_humanized,
             (#{status_changes}) status_changes,
             (#{agency_ids}) agency_ids,
             (#{communications}) communications
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
        rr["status_changes"] = JSON.parse(rr["status_changes"] || "[]")
        rr["agency_ids"] = JSON.parse(rr["agency_ids"] || "[]").map{|ggid| ggid["id"]}
        rr["communications"] = JSON.parse(rr["communications"] || "[]")
        rr
      end
    end

    def communications
      <<-SQL
        select array_to_json(array_agg(row_to_json(cc)))
        from ( select *, ( select row_to_json(u)
                           from (select id, concat("firstName", ' ', "lastName") first_last_name
                                 from users
                                 where communications.user_id = users.id) u
                         ) as user,
                         ( select array_to_json(array_agg(row_to_json(cd)))
                           from (select communication_id, file_id, filename, filesize, id, "lastModifiedDate", original_type, title, user_id from communication_documents) cd
                         ) as attached_documents,
                         ( select array_to_json(array_agg(row_to_json(cc)))
                           from (select address, email, id, name, organization_id, phone, title_key from communicants) cc
                         ) as communicants
               from communications
               where communications.complaint_id = complaints.id
               order by created_at desc ) cc
      SQL
    end

    def agency_ids
      <<-SQL
        select array_to_json(array_agg(row_to_json(aa)))
        from (select agency_id as id, complaint_id
              from complaint_agencies
              join complaints
              on complaint_agencies.complaint_id = complaints.id ) aa
        where aa.complaint_id = complaints.id
      SQL
    end

    def status_changes
      <<-SQL
        select array_to_json(array_agg(row_to_json(sc)))
        from (select change_date as date, (select complaint_statuses.name
                                           from complaint_statuses
                                           join status_changes
                                           on status_changes.complaint_status_id = complaint_statuses.id
                                           where status_changes.complaint_id = complaints.id ) status_humanized,
                                           (select concat("firstName", ' ', "lastName")
                                            from users
                                            join status_changes
                                            on status_changes.user_id = users.id
                                            where status_changes.complaint_id = complaints.id) user_name
              from status_changes
              where status_changes.complaint_id = complaints.id) sc
      SQL
    end

    def current_status_humanized
      <<-SQL
        select complaint_statuses.name
        from complaint_statuses
          join status_changes
          on status_changes.complaint_status_id = complaint_statuses.id
          and status_changes.id = (select max(id) from status_changes where status_changes.complaint_id = complaints.id)
      SQL
    end

    def current_assignee_id
      <<-SQL
      select users.id
      from users
        join assigns
          on assigns.user_id = users.id
          and assigns.created_at = (select max(created_at) from assigns where assigns.complaint_id = complaints.id)
      SQL
    end

    def current_assignee_name
      <<-SQL
      select concat("firstName", ' ', "lastName")
      from users
        join assigns
          on assigns.user_id = users.id
        and assigns.created_at = (select max(created_at) from assigns where assigns.complaint_id = complaints.id)
      SQL
    end

    def special_investigations_unit_complaint_basis_ids
      complaint_basis_ids("Siu::ComplaintBasis", "SpecialInvestigationsUnit")
    end

    def human_rights_complaint_basis_ids
      <<-SQL
      select array_to_json(array_agg(row_to_json(gg)))
      from ( select conventions.id, complaint_complaint_bases.complaint_id
                               from complaint_complaint_bases
                               join conventions
                                 on complaint_complaint_bases.complaint_basis_id = conventions.id
                               where
                                 complaint_complaint_bases.type = 'ComplaintHumanRightsComplaintBasis' ) gg
      where gg.complaint_id = complaints.id
      SQL
    end

    def good_governance_complaint_basis_ids
      complaint_basis_ids("GoodGovernance::ComplaintBasis","GoodGovernance")
    end

    def complaint_basis_ids(cb_type,ccb_type)
      <<-SQL
      select array_to_json(array_agg(row_to_json(gg)))
      from ( select complaint_bases.id, complaint_complaint_bases.complaint_id
                               from complaint_complaint_bases
                               join complaint_bases
                                 on complaint_complaint_bases.complaint_basis_id = complaint_bases.id
                               where
                                 complaint_complaint_bases.type = 'Complaint#{ccb_type}ComplaintBasis' and
                                 complaint_bases.type = '#{cb_type}' ) gg
      where gg.complaint_id = complaints.id
      SQL
    end

    def attached_documents
      url = Rails.application.routes.url_helpers.complaint_document_path(I18n.locale, 'id')
      <<-SQL
      select array_to_json(array_agg(row_to_json(dd)))
      from (select complaint_id, file_id, filename, filesize, id, "lastModifiedDate", original_type, (select '#{ComplaintDocument.serialization_key}')  serialization_key, title, (select replace('#{url}','id',cast(id as varchar))) url, user_id
            from complaint_documents ) dd
      where dd.complaint_id = complaints.id
      SQL
    end

    def assigns
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

    def notes
      author_name = %Q{(select concat("firstName", ' ', "lastName") from users where users.id = notes.author_id) author_name}
      editor_name = %Q{(select concat("firstName", ' ', "lastName") from users where users.id = notes.editor_id) editor_name}
      url = %Q{(select concat('/#{I18n.locale}/complaints/', complaints.id, '/notes/', notes.id)) url} #/:locale/complaints/:complaint_id/notes/:id
      date = %Q{(select to_char(created_at, 'Mon FMDD, YYYY')) date}
      updated_on = %Q{(select to_char(updated_at, 'Mon FMDD, YYYY')) updated_on}
      notes = <<-SQL
      select array_to_json(array_agg(row_to_json(nn)))
      from (select notes.*, #{author_name}, #{editor_name}, #{url}, #{date}, #{updated_on} from notes where notes.notable_id = complaints.id) nn
      SQL
    end
  end
end
