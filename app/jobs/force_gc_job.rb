class ForceGcJob < ApplicationJob
  queue_as :default

  def perform
    logger.debug(GC.stat)
    GC.start
  end
end
