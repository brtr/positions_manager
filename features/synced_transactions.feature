Feature: Synced Transactions pages
  Background:
    Given I have 10 synced transactions

  @javascript
  Scenario: Visit Synced transactions page
    When I visit the '/synced_transactions' page
    Then I see '总投入' text
    Then I see '10' text
    Then I see '总盈利' text
    Then I see '10' text
    Then I see 'ETH' text
    When I select2 "BTCUSDT" from "#search" filter
     And I click on the button "确定"
    Then I should not see content "ETH" within "#trading-histories-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text

  @javascript
  Scenario: Visit Synced transactions page with sort
    When I visit the '/synced_transactions' page
    Then I see '交易对' text
    Then I see '成本价' text
    When I click on the '成交金额' link
     And I am waiting for ajax
    Then I should see content "ETH" within "#trading-histories-container > table > tbody > tr:nth-child(1)"
    When I click on the '成交金额' link
     And I am waiting for ajax
    Then I should see content "BTC" within "#trading-histories-container > table > tbody > tr:nth-child(1)"
    When I click on the '收益' link
     And I am waiting for ajax
    Then I should see content "ETH" within "#trading-histories-container > table > tbody > tr:nth-child(1)"
    When I click on the '收益' link
     And I am waiting for ajax
    Then I should see content "BTC" within "#trading-histories-container > table > tbody > tr:nth-child(1)"