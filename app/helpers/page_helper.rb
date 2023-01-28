module PageHelper
  def adding_positions_summary(data)
    max_amount_record = data.sort_by{|d| d["amount"].to_f}.reverse.first
    rate = data.select{|d| d["revenue"].to_f > 0}.sum{|d| d["revenue"].to_f} / data.select{|d| d["revenue"].to_f < 0}.sum{|d| d["revenue"].to_f}
    {
      total_amount: data.sum{|d| d["amount"].to_f}.round(3),
      max_symbol: max_amount_record["symbol"],
      max_amount: max_amount_record["amount"].to_f.round(3),
      rate: (rate.abs * 100).round(3)
    }
  end
end
