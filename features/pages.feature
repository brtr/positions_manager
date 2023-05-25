Feature: Public pages
  Background:
    Given I have 10 user positions
    Given I have different snapshots
    Given I have 10 user spot balances

  @javascript
  Scenario: Visit Public positions page
    When I visit the '/' page
    Then I see '总投入' text
    Then I see '(-124.7985)' text
    Then I see '绝对收益' text
    Then I see '(392.5504)' text
    Then I see '(3.7202)' text
    Then I see 'EOS' text
    When I select2 "BTCUSDT" from "#search" filter
     And I click on the button "确定"
    Then I should not see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text
    When I fill '2022-11-05' into the 'compare_date' field
     And I click on the button "确定"
    Then I see '总投入' text
    Then I see '-6.7985' text
    Then I see '绝对收益' text
    Then I see '345.017' text

  @javascript
  Scenario: Visit Public positions page with sort
    When I visit the '/' page
    Then I see '交易对' text
    Then I see '成本价' text
    When I click on the '预计收益' link
     And I am waiting for ajax
    Then I should see content "BTC" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    When I click on the '预计收益' link
     And I am waiting for ajax
    Then I should see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    When I click on the '收益差额' link
     And I am waiting for ajax
    Then I should see content "BTC" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    When I click on the '收益差额' link
     And I am waiting for ajax
    Then I should see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"

  @javascript
  Scenario: Visit Public spot balances page
    When I visit the '/public_spot_balances' page
    Then I see '现货仓位管理' text
    Then I see 'EOS' text
    When I select2 "BTCUSDT" from "#search" filter
     And I click on the button "确定"
    Then I should not see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text