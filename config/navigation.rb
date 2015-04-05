SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :nhri, t('layout.nav.nhri') do |nhri|
      nhri.item :hre, t('layout.nav.hre'), placeholder_path
      nhri.item :adv_council, t('layout.nav.adv_council'), placeholder_path
      nhri.item :nhr_indicators, t('layout.nav.nhr_indicators'), placeholder_path
      nhri.item :hr_prot, t('layout.nav.hr_prot'), placeholder_path
      nhri.item :icc, t('layout.nav.icc'), placeholder_path
    end
    primary.item :gg, t('layout.nav.gg') do |gg|
      gg.item :action, '??',placeholder_path
    end
    primary.item :corporate_services, t('layout.nav.corporate_services') do |cs|
      cs.item :int_docs, t('layout.nav.int_docs'), placeholder_path
      cs.item :perf_rev, t('layout.nav.perf_rev'), placeholder_path
      cs.item :strat_plan, t('layout.nav.strat_plan'), placeholder_path
    end
    primary.item :outreach_media, t('layout.nav.outreach_media') do |om|
      om.item :outreach, t('layout.nav.outreach'), placeholder_path
      om.item :media, t('layout.nav.media'), placeholder_path
    end
    primary.item :spec_inv, t('layout.nav.spec_inv'), placeholder_path
    primary.item :reports, t('layout.nav.reports'), placeholder_path
    primary.item :admin, t('layout.nav.admin'), :if => Proc.new{ current_user.is_admin? || current_user.is_developer? } do |ad|
      ad.item :users, t('layout.nav.user'), admin_users_path
      ad.item :roles, t('layout.nav.role'), authengine_roles_path
      ad.item :organizations, t('layout.nav.organization'), admin_organizations_path
      ad.item :access, t('layout.nav.access'), authengine_action_roles_path
    end
    primary.item :logout, t('layout.nav.logout'), logout_path
    primary.dom_class = 'nav navbar-nav'
  end
end


