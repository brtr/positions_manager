Feature: Ranking Snapshots pages
  Background:
    Given I have 2 ranking snapshots

  @javascript
  Scenario: Visit Snapshot Info Index page
    When I visit the '/ranking_snapshots' page
    Then I see '2023' text
    Then I see '1月' text
    Then I see '5' text
    Then I see '2月' text
    Then I see '8' text

  @javascript
  Scenario: Visit Snapshot Info Show page
    When I visit the '/ranking_snapshots' page
    Then I see '1月' text
    Then I see '5' text
    When I click on the '5' link
     And I am waiting for ajax
    Then I see '2023-1-5币种涨跌排名列表' text
    Then I see 'BTCUSDT' text

  @javascript
  Scenario: Visit Ranking Snapshots page
    When I visit the '/ranking_snapshots/short_selling_tools' page
    Then I see '最近24小时币种涨跌排名列表' text
    Then I see '币种' text
    Then I see 'BTCUSDT' text
    Then I see '24小时涨幅' text
    Then I see '75.0 %' text

  @javascript
  Scenario: Visit Ranking Snapshots page
    When I visit the '/ranking_snapshots/long_selling_tools' page
    Then I see '距离顶部下跌幅度的排行' text
    Then I see '币种' text
    Then I see 'ENJUSDT' text
    Then I see '距离顶部下跌幅度' text
    Then I see '90.0 %' text