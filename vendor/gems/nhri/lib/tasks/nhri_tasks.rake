namespace :nhri do
  desc "populate all nhri modules"
  task :populate => [:populate_ref_docs, :populate_tor, :populate_mem, :populate_min, :populate_iss, :populate_ind_etc]
end
