Feature: User Synced Positions pages
  Background:
    Given I am a new, authenticated user
    Given I have 10 user synced positions with user id
    Given I have synced snapshot with user id

  @javascript
  Scenario: Visit User Synced positions page
    When I visit the '/user_synced_positions' page
    Then I see '总投入' text
    Then I see '(-138.419)' text
    Then I see '总盈利' text
    Then I see '(378.93)' text
    Then I see 'EOS' text
    When I fill 'BTC' into the 'search' field
     And I click on the button "确定"
    Then I should not see 'EOS' text
    Then I see 'BTC' text