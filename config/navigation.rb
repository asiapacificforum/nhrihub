SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.item :nhri, t('layout.nav.nhri') do |nhri|
      nhri.item :hre, t('layout.nav.hre'), home_path
      nhri.item :adv_council, t('layout.nav.adv_council'), home_path
      nhri.item :nhr_indicators, t('layout.nav.nhr_indicators'), home_path
      nhri.item :hr_prot, t('layout.nav.hr_prot'), home_path
      nhri.item :icc, t('layout.nav.icc'), home_path
    end
    primary.item :gg, t('layout.nav.gg') do |gg|
      gg.item :action, '??',home_path
    end
    primary.item :corporate_services, t('layout.nav.corporate_services') do |cs|
      cs.item :int_docs, t('layout.nav.int_docs'), home_path
      cs.item :perf_rev, t('layout.nav.perf_rev'), home_path
      cs.item :strat_plan, ('layout.nav.strat_plan'), home_path
    end
    primary.item :outreach_media, t('layout.nav.outreach_media') do |om|
      om.item :outreach, t('layout.nav.outreach'), home_path
      om.item :media, t('layout.nav.media'), home_path
    end
    primary.item :spec_inv, t('layout.nav.spec_inv'), home_path
    primary.item :reports, t('layout.nav.reports'), home_path
    primary.item :admin, t('layout.nav.admin'), :if => Proc.new{ current_user.is_admin? || current_user.is_developer? } do |ad|
      ad.item :users, t('layout.nav.user'), admin_users_path
    end
    primary.item :logout, t('layout.nav.logout'), logout_path
    primary.dom_class = 'nav navbar-nav'
  end
end


