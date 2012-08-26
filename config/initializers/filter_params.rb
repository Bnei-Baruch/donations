class ActionDispatch::Request
  def filtered_path
    fullpath = super.gsub(/ccno=[^&]+/, 'ccno=[FILTERED]')
    fullpath.gsub!(/mycvv=[^&]+/, 'mycvv=[FILTERED]')
    fullpath.gsub!(/myid=[^&]+/, 'myid=[FILTERED]')
    fullpath.gsub!(/sum=[^&]+/, 'sum=[FILTERED]')
    fullpath
  end
end

