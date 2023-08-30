Feature: Position detail page
  Background:
    Given I have 10 adding positions histories

  @javascript
  Scenario: Visit Position detail page
    When I visit the position detail page with 3rd party service
    Then I see '历史投入' text
    Then I see '未平仓投入列表' text
    Then I see '已平仓投入列表' text
    Then I see 'ETH' text
    Then I see '30.7202' text
    Then I click on the 'Refresh' link
    Then I see '正在更新，请稍等刷新查看最新结果...' text