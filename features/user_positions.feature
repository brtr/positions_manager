Feature: User Positions pages
  Background:
    Given I am a new, authenticated user
    Given I have 10 user positions with user id
    Given I have synced snapshot with user id

  @javascript
  Scenario: Visit User positions page
    When I visit the '/user_positions' page
    Then I see '总投入' text
    Then I see '(307.2)' text
    Then I see '绝对收益' text
    Then I see '(157.22)' text
    Then I see 'EOS' text
    When I select2 "BTCUSDT" from "#search" filter
     And I click on the button "确定"
    Then I should not see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text

  @javascript
  Scenario: Visit User positions page with sort
    When I visit the '/user_positions' page
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