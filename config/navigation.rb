SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :compl, t('layout.nav.complaints'), complaints_path
    primary.item :proj, t('layout.nav.projects'), projects_path
    primary.item :doc, t('layout.nav.int_docs'), internal_documents_path
    primary.item :nhri, t('layout.nav.nhri') do |nhri|
      nhri.item :adv_council, t('layout.nav.adv_council'), :class => 'dropdown-submenu' do |adv|
        adv.item :tor, t('layout.nav.adv.tor'), nhri_advisory_council_terms_of_references_path
        adv.item :memb, t('layout.nav.adv.memb'), nhri_advisory_council_members_path
        adv.item :min, t('layout.nav.adv.min'), nhri_advisory_council_minutes_index_path
        adv.item :issues, t('layout.nav.adv.issues'), nhri_advisory_council_issues_path
      end
      nhri.item :headings, t('layout.nav.headings'), nhri_headings_path
      nhri.item :icc, t('layout.nav.icc.icc'), :class => 'dropdown-submenu' do |icc|
        icc.item :icc_int, t('layout.nav.icc.int'), nhri_icc_index_path
        icc.item :icc_ref, t('layout.nav.icc.ref'), nhri_icc_reference_documents_path
      end
    end
    primary.item :strat_plan, t('layout.nav.strat_plan') do |st_pl|
      StrategicPlan.all.each do |sp|
        st_pl.item :sp_item, menu_text(sp), corporate_services_strategic_plan_path(sp.id)
      end
      if StrategicPlan.count.zero?
        st_pl.item :sp_item, "none configured", corporate_services_admin_path, :highlights_on => /corporate_services\/strategic_plans/
      end
    end
    primary.item :media, t('layout.nav.media'), media_appearances_path
    primary.item :admin, t('layout.nav.admin'), :if => Proc.new{ current_user.is_admin? || current_user.is_developer? } do |ad|
      ad.item :users, t('layout.nav.user'), admin_users_path
      ad.item :roles, t('layout.nav.role'), authengine_roles_path
      ad.item :organizations, t('layout.nav.organization'), admin_organizations_path
      ad.item :access, t('layout.nav.access'), authengine_action_roles_path
      ad.item :nhri, t('layout.nav.nhri'), nhri_admin_path
      ad.item :gg, t('layout.nav.projects'), project_admin_path
      ad.item :corp_svcs, t('layout.nav.strat_plan'), corporate_services_admin_path
      ad.item :or_media, t('layout.nav.media'), media_appearance_admin_path
      ad.item :compl, t('layout.nav.complaints'), complaint_admin_path
      ad.item :doc, t('layout.nav.int_docs'), internal_document_admin_path
      ad.item :dash, t('layout.nav.dashboard'), dashboard_index_path
    end
    primary.item :logout, t('layout.nav.logout'), logout_path
    primary.dom_class = 'nav navbar-nav'
  end
end
