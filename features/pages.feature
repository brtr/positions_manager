Feature: Public pages
  Background:
    Given I have 10 user positions
    Given I have a yesterday snapshot
    Given I have a last week snapshot

  @javascript
  Scenario: Visit Public positions page
    When I visit the '/' page
    Then I see '总投入' text
    Then I see '-416.599' text
    Then I see '总盈利' text
    Then I see '416.084' text
    Then I see 'EOS' text
    When I fill 'BTC' into the 'search' field
    And I click on the button "确定"
    Then I should not see 'EOS' text
    Then I see 'BTC' text
    When I fill '2022-12-01' into the 'compare_date' field
    And I click on the button "确定"
    Then I see '总投入' text
    Then I see '-284.999' text
    Then I see '总盈利' text
    Then I see '369.017' text

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