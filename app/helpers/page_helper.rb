module PageHelper
  def adding_positions_summary(data)
    return {} if data.empty?
    max_amount_record = data.sort_by{|d| d.amount}.reverse.first
    total_amount = data.sum{|d| d.amount}
    rate = data.sum{|d| d.revenue} / total_amount
    {
      total_amount: total_amount.round(4),
      max_symbol: max_amount_record.origin_symbol,
      max_amount: max_amount_record.amount.round(4),
      rate: (rate * 100).round(4)
    }
  end

  def account_balance_format(data, source_type)
    if source_type == :binance
      {rate: data['totalMaintMargin'].to_f / data['totalMarginBalance'].to_f}.merge(data)
    else
      data["data"][0]["details"].select{|x| x["ccy"] == "USDT"}.first
    end
  end
end
