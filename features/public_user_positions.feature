Feature: Public user positions page
  Background:
    Given I have 10 user positions
    Given I have different snapshots
    Given I have 10 user spot balances

  @javascript
  Scenario: Visit Public positions page
    When I visit the '/' page
    Then I see '总投入' text
    Then I see '(-124.8)' text
    Then I see '绝对收益' text
    Then I see '(392.55)' text
    Then I see 'EOS' text
    When I select2 "BTCUSDT" from "#search" filter
     And I click on the button "确定"
    Then I should not see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text
    When I fill '2022-11-05' into the 'compare_date' field
     And I click on the button "确定"
    Then I see '总投入' text
    Then I see '-6.8' text
    Then I see '绝对收益' text
    Then I see '345.02' text

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