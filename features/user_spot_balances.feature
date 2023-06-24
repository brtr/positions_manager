Feature: User Spot Balance pages
  Background:
    Given I am a new, authenticated user
    Given I have 10 user spot balances with user id

  @javascript
  Scenario: Visit User spot balances page
    When I visit the '/user_spot_balances' page
    Then I see '币种' text
    Then I see '成本价' text
    Then I see 'EOS' text
    Then I see 'BTC' text
    When I select2 "BTCUSDT" from "#search" filter
     And I click on the button "确定"
    Then I should not see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text