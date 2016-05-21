SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :nhri, t('layout.nav.nhri') do |nhri|
      nhri.item :pro, t('layout.nav.pro.pro'), :class => 'dropdown-submenu' do |pro|
        pro.item :doc, t('layout.nav.int_docs'), nhri_protection_promotion_internal_documents_path
        pro.item :proj, t('layout.nav.projects'), nhri_protection_promotion_projects_path
      end
      nhri.item :adv_council, t('layout.nav.adv_council'), :class => 'dropdown-submenu' do |adv|
        adv.item :tor, t('layout.nav.adv.tor'), nhri_advisory_council_terms_of_references_path
        adv.item :memb, t('layout.nav.adv.memb'), nhri_advisory_council_members_path
        adv.item :min, t('layout.nav.adv.min'), nhri_advisory_council_minutes_index_path
        adv.item :issues, t('layout.nav.adv.issues'), nhri_advisory_council_issues_path
      end
      nhri.item :headings, t('layout.nav.headings'), nhri_headings_path
      nhri.item :hr_prot, t('layout.nav.complaints'), nhri_complaints_path
      nhri.item :icc, t('layout.nav.icc.icc'), :class => 'dropdown-submenu' do |icc|
        icc.item :icc_int, t('layout.nav.icc.int'), nhri_icc_index_path
        icc.item :icc_ref, t('layout.nav.icc.ref'), nhri_icc_reference_documents_path
      end
    end
    primary.item :gg, t('layout.nav.gg.gg') do |gg|
      gg.item :int_docs, t('layout.nav.int_docs'), good_governance_internal_documents_path
      gg.item :complaints, t('layout.nav.complaints'), good_governance_complaints_path
      gg.item :proj, t('layout.nav.projects'), good_governance_projects_path
    end
    primary.item :corporate_services, t('layout.nav.corporate_services') do |cs|
      cs.item :int_docs, t('layout.nav.int_docs'), corporate_services_internal_documents_path
      cs.item :strat_plan, t('layout.nav.strat_plan'), corporate_services_strategic_plan_path("current")
    end
    primary.item :outreach_media, t('layout.nav.outreach_media') do |om|
      om.item :outreach, t('layout.nav.outreach'), outreach_media_outreach_events_path
      om.item :media, t('layout.nav.media'), outreach_media_media_appearances_path
    end
    primary.item :spec_inv, t('layout.nav.spec_inv') do |siu|
      siu.item :int_docs, t('layout.nav.int_docs'), siu_internal_documents_path
      siu.item :complaints, t('layout.nav.complaints'), siu_complaints_path
      siu.item :proj, t('layout.nav.projects'), siu_projects_path
    end
    primary.item :reports, t('layout.nav.reports'), placeholder_path
    primary.item :admin, t('layout.nav.admin'), :if => Proc.new{ current_user.is_admin? || current_user.is_developer? } do |ad|
      ad.item :users, t('layout.nav.user'), admin_users_path
      ad.item :roles, t('layout.nav.role'), authengine_roles_path
      ad.item :organizations, t('layout.nav.organization'), admin_organizations_path
      ad.item :access, t('layout.nav.access'), authengine_action_roles_path
      ad.item :nhri, t('layout.nav.nhri'), nhri_admin_path
      ad.item :gg, t('layout.nav.projects'), project_admin_path
      ad.item :corp_svcs, t('layout.nav.corporate_services'), corporate_services_admin_path
      ad.item :or_media, t('layout.nav.outreach_media'), outreach_media_admin_path
      ad.item :compl, t('layout.nav.complaints'), complaint_admin_path
    end
    primary.item :logout, t('layout.nav.logout'), logout_path
    primary.dom_class = 'nav navbar-nav'
  end
end
