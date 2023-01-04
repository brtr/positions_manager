# frozen_string_literal: true

module WaitForTurbolinksAjax
  TURBOLINKS_CSS_SELECTOR = '.turbolinks-progress-bar'.freeze

  def wait_for_turbolinks_ajax
    has_css? TURBOLINKS_CSS_SELECTOR, visible: true
    has_no_css? TURBOLINKS_CSS_SELECTOR, wait: Capybara.default_max_wait_time
  end
end

World(WaitForTurbolinksAjax)