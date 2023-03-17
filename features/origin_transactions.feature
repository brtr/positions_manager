Feature: Origin Transactions pages
  Background:
    Given I have 10 origin transactions

  @javascript
  Scenario: Visit Origin transactions page
    When I visit the '/origin_transactions' page
    Then I see '总投入' text
    Then I see '20' text
    Then I see '总盈利' text
    Then I see '10' text
    Then I see 'EOS' text
    When I select2 "test2" from "#campaign" filter
     And I am waiting for ajax
    Then I should not see content "EOS" within "#trading-histories-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text

  @javascript
  Scenario: Visit Origin transactions page with sort
    When I visit the '/origin_transactions' page
    Then I see '交易对' text
    Then I see '成本价' text
    When I click on the '预计收益' link
     And I am waiting for ajax
    Then I should see content "EOS" within "#trading-histories-container > table > tbody > tr:nth-child(1)"
    When I click on the '预计收益' link
     And I am waiting for ajax
    Then I should see content "BTC" within "#trading-histories-container > table > tbody > tr:nth-child(1)"
    When I click on the '预计ROI' link
     And I am waiting for ajax
    Then I should see content "EOS" within "#trading-histories-container > table > tbody > tr:nth-child(1)"
    When I click on the '预计ROI' link
     And I am waiting for ajax
    Then I should see content "BTC" within "#trading-histories-container > table > tbody > tr:nth-child(1)"