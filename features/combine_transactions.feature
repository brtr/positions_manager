Feature: Combine Transactions pages
  Background:
    Given I have 2 combine transactions

  @javascript
  Scenario: Visit Combine transactions page
    When I visit the '/combine_transactions' page
    Then I see '总投入' text
    Then I see '10' text
    Then I see '总盈利' text
    Then I see '20' text
    Then I see 'EOS' text

  @javascript
  Scenario: Visit Combine transactions page with sort
    When I visit the '/combine_transactions' page
    Then I see '交易对' text
    Then I see '成交价' text
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