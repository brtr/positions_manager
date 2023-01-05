Feature: Snapshot Info pages
  Background:
    Given I have different snapshots

  @javascript
  Scenario: Visit Snapshot Info Index page
    When I visit the '/snapshot_infos' page
    Then I see '12月' text
    Then I see '10' text
    Then I see '11月' text
    Then I see '5' text

  @javascript
  Scenario: Visit Snapshot Info Show page
    When I visit the '/snapshot_infos' page
    Then I see '12月' text
    Then I see '10' text
    When I click on the '10' link
     And I am waiting for ajax
    Then I see '合约仓位历史快照 - 2022-12-10' text
    Then I see 'EOS' text
    When I fill "BTC" into the "search" field
     And I click on the button "确定"
    Then I should not see "EOS" text
     And I should see content "BTC" within "#position-histories-container"

  @javascript
  Scenario: Visit Snapshot Position Graphs page
    When I visit the '/snapshot_infos/positions_graphs' page
    Then I see '历史仓位变化曲线图' text
    Then I see '历史收益占比中位数' text