Feature: User Synced Positions pages
  Background:
    Given I am a new, authenticated user
    Given I have 10 user synced positions with user id
    Given I have synced snapshot with user id

  @javascript
  Scenario: Visit User Synced positions page
    When I visit the '/user_synced_positions' page
    Then I see '总投入' text
    Then I see '(-138.42)' text
    Then I see '绝对收益' text
    Then I see '(378.93)' text
    Then I see 'EOS' text
    When I select2 "BTCUSDT" from "#search" filter
     And I click on the button "确定"
    Then I should not see content "EOS" within "#user-positions-container > table > tbody > tr:nth-child(1)"
    Then I see 'BTC' text