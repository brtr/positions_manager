module PageHelper
  def adding_positions_summary(data)
    return {} if data.empty?
    max_amount_record = data.sort_by{|d| d["amount"].to_f}.reverse.first
    total_amount = data.sum{|d| d["amount"].to_f}
    rate = data.sum{|d| d["revenue"].to_f} / total_amount
    {
      total_amount: total_amount.round(3),
      max_symbol: max_amount_record["symbol"],
      max_amount: max_amount_record["amount"].to_f.round(3),
      rate: (rate * 100).round(3)
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
