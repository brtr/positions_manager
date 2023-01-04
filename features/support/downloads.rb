module DownloadHelpers
  TIMEOUT = 10
  PATH    = Rails.root.join("tmp/downloads")

  module_function

  def downloads
    Dir[PATH.join("*")]
  end

  def download
    wait_for_download
    downloads.first
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end

World(DownloadHelpers)

Before do
  clear_downloads
end

After do
  clear_downloads
end