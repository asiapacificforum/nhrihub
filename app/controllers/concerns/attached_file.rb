module AttachedFile
  def send_attached_file(file_owner)
    send_opts = { :filename => file_owner.send(:original_filename),
                  :type => file_owner.send(:original_type),
                  :disposition => :attachment }
    send_file file_owner.send(:file).to_io, send_opts
  end
end
