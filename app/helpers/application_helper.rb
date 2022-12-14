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
        name: "成本价",
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
        name: "预计ROI",
        sort: "roi"
      },
      {
        name: "预计收益/总收益",
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

  def position_amount_display(h, s=nil)
    str = "#{h.amount.round(4)} #{h.fee_symbol}"
    margin = h.amount - s.amount rescue 0
    return str if s.nil? || margin == 0 || (margin > 0 && margin < 1) || (margin < 0 && margin > -1)
    str += "(<span class=#{margin > 0 ? 'pos-num' : 'neg-num'}>#{margin.round(4)}</span>)"
    str.html_safe
  end

  def position_revenue_display(h, s=nil)
    str = "<span class=#{h.revenue > 0 ? 'pos-num' : 'neg-num'}>#{h.revenue.round(4)} #{h.fee_symbol}</span>"
    return str.html_safe if s.nil?
    str += "(<span class=#{s.revenue > 0 ? 'pos-num' : 'neg-num'}>#{s.revenue.round(4)}</span>)"
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

  def get_roi(total_summary)
    roi = total_summary[:total_cost].to_f == 0 ? 0 : ((total_summary[:total_revenue].to_f / total_summary[:total_cost].to_f) * 100).round(3)
    "<span class=#{roi > 0 ? 'pos-num' : 'neg-num'}>#{roi}%</span>".html_safe
  end

  def last_summary_display(data)
    if data.to_f >= 1 || data.to_f <= -1
      c = data > 0 ? 'pos-num' : 'neg-num'
      "(<span class='#{c}'>#{data}</span>)".html_safe
    end
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
end
