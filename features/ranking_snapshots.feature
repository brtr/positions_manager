Feature: Ranking Snapshots pages
  Background:
    Given I have 2 ranking snapshots

  @javascript
  Scenario: Visit Ranking Snapshots page
    When I visit the '/ranking_snapshots' page
    Then I see '最近24小时币种涨跌排名列表' text
    Then I see '币种' text
    Then I see 'BTCUSDT' text
    Then I see '24小时涨幅' text
    Then I see '75.0 %' text