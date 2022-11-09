module ApplicationHelper
  def positions_table_headers
    [
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
        sort: "cost_ratio"
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
        sort: "revenue_ratio"
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

  def change_sort_type(sort)
    sort == 'asc' ? "desc" : "asc"
  end

  def ch_remote_params(params,sort)
    res = {
      sort: sort,
      sort_type: "#{change_sort_type(params[:sort_type])}",
      search: params[:search],
    }
    res.merge(user_id: params[:user_id]) if params[:user_id]
    res
  end

  def get_refresh_time(user_id=nil)
    redis_key = user_id.present? ? "get_user_#{user_id}_positions_refresh_time" : "get_user_positions_refresh_time"
    time = $redis.get(redis_key).to_datetime rescue ''
    time == '' ? '' : "#{time_ago_in_words(time)} 之前"
  end

  def position_amount_display(h, s=nil)
    str = "#{h.amount.round(4)} #{h.fee_symbol}"
    margin = h.amount - s.amount rescue 0
    return str if s.nil? || margin.to_f == 0
    str += "(<span class=#{margin > 0 ? 'pos-num' : 'neg-num'}>#{margin.round(4)}</span>)"
    str.html_safe
  end

  def position_revenue_display(h)
    str = "#{h.revenue.round(4)} #{h.fee_symbol}"
    last_revenue = h.last_revenue.to_f
    str += "(<span class=#{last_revenue > 0 ? 'pos-roi' : 'neg-roi'}>#{last_revenue.round(4)}</span>)"
    str.html_safe
  end

  def trade_type_style(trade_type)
    trade_type.to_s.downcase == 'sell' ? "text-danger" : "text-success"
  end

  def display_symbol(h, s=nil)
    str = "#{h.from_symbol} / #{h.fee_symbol}"
    return str if s.present?
    "(新) " + str
  end
end
