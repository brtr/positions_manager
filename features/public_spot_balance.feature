Feature: Public pages
  Background:
    Given I have 10 user spot balances

  @javascript
  Scenario: Visit Public spot balances page
    When I visit the '/public_spot_balances' page
    Then I see '现货仓位管理' text
    Then I see 'EOS' text
    When I select2 "BTCUSDT" from "#search" filter
     And I click on the button "确定"
    Then I should not see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text