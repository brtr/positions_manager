module ApplicationHelper
  def positions_table_headers
    [
      {
        name: "交易对",
        sort: "none"
      },
      {
        name: "最新排名",
        sort: "ranking"
      },
      {
        name: "资金费用",
        sort: "funding_fee"
      },
      {
        name: "类别",
        sort: "none"
      },
      {
        name: "成本价",
        sort: "price"
      },
      {
        name: "当前价",
        sort: "none"
      },
      {
        name: "数量",
        sort: "qty"
      },
      {
        name: "总投入",
        sort: "amount"
      },
      {
        name: "币种投入/总投入",
        sort: "none"
      },
      {
        name: "预计收益",
        sort: "revenue"
      },
      {
        name: "收益差额",
        sort: "margin_revenue"
      },
      {
        name: "预计ROI",
        sort: "roi"
      },
      {
        name: "预计收益/总收益",
        sort: "none"
      },
      {
        name: "下跌/上升比例",
        sort: "margin_ratio"
      },
      {
        name: "来源",
        sort: "none"
      }
    ]
  end

  def transactions_table_headers
    [
      {
        name: "交易时间",
        sort: "event_time"
      },
      {
        name: "交易对",
        sort: "none"
      },
      {
        name: "类别",
        sort: "none"
      },
      {
        name: "成交价",
        sort: "none"
      },
      {
        name: "当前价",
        sort: "none"
      },
      {
        name: "数量",
        sort: "none"
      },
      {
        name: "交易金额",
        sort: "amount"
      },
      {
        name: "币种投入/总投入",
        sort: "none"
      },
      {
        name: "预计收益 / 实际收益",
        sort: "revenue"
      },
      {
        name: "预计ROI / 实际ROI",
        sort: "roi"
      },
      {
        name: "收益/总收益",
        sort: "none"
      },
      {
        name: "来源",
        sort: "none"
      }
    ]
  end

  def synced_transactions_table_headers
    [
      {
        name: "交易时间",
        sort: "event_time"
      },
      {
        name: "交易对",
        sort: "none"
      },
      {
        name: "类别",
        sort: "none"
      },
      {
        name: "成本价",
        sort: "none"
      },
      {
        name: "数量",
        sort: "none"
      },
      {
        name: "总投入",
        sort: "none"
      },
      {
        name: "成交价",
        sort: "none"
      },
      {
        name: "成交金额",
        sort: "amount"
      },
      {
        name: "手续费",
        sort: "fee"
      },
      {
        name: "收益",
        sort: "revenue"
      },
      {
        name: "ROI",
        sort: "roi"
      },
      {
        name: "来源",
        sort: "none"
      }
    ]
  end

  def adding_positions_history_headers
    [
      {
        name: "投入日期",
        sort: "none"
      },
      {
        name: "币种",
        sort: "none"
      },
      {
        name: "类别",
        sort: "none"
      },
      {
        name: "平均成本价",
        sort: "none"
      },
      {
        name: "最新价格",
        sort: "none"
      },
      {
        name: "新增数量",
        sort: "qty"
      },
      {
        name: "新增金额",
        sort: "amount"
      },
      {
        name: "新增收益",
        sort: "get_revenue"
      },
      {
        name: "新增收益占新增金额的占比",
        sort: "roi"
      },
      {
        name: "新增金额占当前该币种总仓位的占比",
        sort: "none"
      },
      {
        name: "来源",
        sort: "none"
      }
    ]
  end

  def spots_table_headers
    [
      {
        name: "币种",
        sort: "none"
      },
      {
        name: "成本价",
        sort: "price"
      },
      {
        name: "当前价",
        sort: "none"
      },
      {
        name: "数量",
        sort: "qty"
      },
      {
        name: "总投入",
        sort: "amount"
      },
      {
        name: "来源",
        sort: "none"
      }
    ]
  end

  def adding_positions_remote_params(params, sort)
    res = {
      sort: sort,
      sort_type: "#{change_sort_type(params[:sort_type])}",
      from_date: params[:from_date],
      to_date: params[:to_date]
    }
    res.merge!(origin_symbol: params[:origin_symbol]) if params[:origin_symbol]
    res
  end

  def change_sort_type(sort)
    sort == 'asc' ? "desc" : "asc"
  end

  def ch_remote_params(params,sort)
    res = {
      sort: sort,
      sort_type: "#{change_sort_type(params[:sort_type])}",
      search: params[:search],
    }
    res.merge!(user_id: params[:user_id]) if params[:user_id]
    res.merge!(compare_date: params[:compare_date]) if params[:compare_date]
    res.merge!(switch_filter: params[:switch_filter]) if params[:switch_filter]
    res
  end

  def get_refresh_time(user_id=nil)
    redis_key = user_id.present? ? "get_user_#{user_id}_positions_refresh_time" : "get_user_positions_refresh_time"
    time = $redis.get(redis_key).to_datetime rescue ''
    time == '' ? '' : "#{time_ago_in_words(time)} 之前"
  end

  def get_synced_refresh_time(user_id=nil)
    time = $redis.get("get_user_#{user_id}_synced_positions_refresh_time").to_datetime rescue ''
    time == '' ? '' : "#{time_ago_in_words(time)} 之前"
  end

  def position_amount_display(h, s=nil, html_safe: true)
    str = "#{h.amount.round(4)} #{h.fee_symbol}"
    margin = h.amount - s.amount rescue 0
    return str if s.nil? || margin == 0 || (margin > 0 && margin < 1) || (margin < 0 && margin > -1)
    if html_safe
      str += "(<span class=#{margin > 0 ? 'pos-num' : 'neg-num'}>#{margin.round(4)}</span>)"
      str.html_safe
    else
      "#{str} (#{margin.round(4)})"
    end
  end

  def position_revenue_display(h, s=nil, html_safe: true)
    if html_safe
      str = "<span class=#{h.revenue > 0 ? 'pos-num' : 'neg-num'}>#{h.revenue.round(4)} #{h.fee_symbol}</span>"
      return str.html_safe if s.nil?
      str += "(<span class=#{s.revenue > 0 ? 'pos-num' : 'neg-num'}>#{s.revenue.round(4)}</span>)"
      str.html_safe
    else
      str = "#{h.revenue.round(4)} #{h.fee_symbol}"
      s.present? ? "#{str} (#{s.revenue.round(4)})" : str
    end
  end

  def trade_type_style(trade_type)
    trade_type.to_s.downcase == 'sell' ? "text-danger" : "text-success"
  end

  def display_symbol(h, s=nil)
    str = "#{h.from_symbol} / #{h.fee_symbol}"
    return str if s.present?
    "(新) " + str
  end

  def get_roi(total_summary)
    roi = total_summary[:total_cost].to_f == 0 ? 0 : ((total_summary[:total_revenue].to_f / total_summary[:total_cost].to_f) * 100).round(4)
    "<span class=#{roi > 0 ? 'pos-num' : 'neg-num'}>#{roi}%</span>".html_safe
  end

  def last_summary_display(data)
    if data.to_f >= 1 || data.to_f <= -1
      c = data > 0 ? 'pos-num' : 'neg-num'
      "(<span class='#{c}'>#{data}</span>)".html_safe
    end
  end

  def daily_market_display(data, is_risen = true)
    c = is_risen ? 'pos-num' : 'neg-num'
    "<span class='#{c}'>#{data}</span>".html_safe
  end

  def price_change_style(data)
    c = data.to_f < 0 ? "text-danger" : "text-success"
    "<span class='#{c}'>#{data}</span>".html_safe
  end

  def get_list_url(source_type, params)
    case source_type
    when :public
      public_user_positions_path(params)
    when :private_synced
      user_synced_positions_path(params)
    else
      user_positions_path(params)
    end
  end

  def get_symbol_url(symbol, source, count = 0)
    str = count.zero? ? symbol : "#{symbol} (#{count})"
    link_to str, ranking_graph_ranking_snapshots_path(symbol: symbol, source: source), remote: true
  end

  def get_top10_count(source, symbol)
    RankingSnapshot.with_top10(source, symbol).count
  end

  def get_date_format(date)
    date.strftime('%Y-%m-%d') rescue ''
  end

  def ranking(symbol)
    symbol = SyncFuturesTickerService.fetch_symbol(symbol)
    CoinRanking.find_by(symbol: symbol.downcase)&.rank
  end

  def trade_type_display(trade_type, qty)
    str = I18n.t("views.contract_trading.#{trade_type}")
    str += "(平仓)" if qty < 0
    str
  end
end
