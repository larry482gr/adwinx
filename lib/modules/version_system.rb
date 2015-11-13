module VersionSystem
  def read_version
    begin
      File.read "#{Rails.root}/config/initializers/version"
    rescue
      raise "VERSION file not found or unreadable.".red
    end
  end
end