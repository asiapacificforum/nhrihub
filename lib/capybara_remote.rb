class CapybaraRemote
  def self.upload_file_path(page, filename)
    if page.evaluate_script("navigator.userAgent").match("Windows") # IE test on remote windows machine
      "c:\\Users\\Public\\Documents\\#{filename}"
    else
      Rails.root.join('spec','support','uploadable_files', filename)
    end
  end

  def self.url
    "http://192.168.1.7:4444/wd/hub"
  end
end
