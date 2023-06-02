class GenerateUserSpotBalanceSnapshotsService
  class << self
    def execute(from_date: '2022-01-01', user_id: nil)
      SpotBalanceSnapshotInfo.transaction do
        (Date.parse(from_date)..Date.today).each do |date|
          info = SpotBalanceSnapshotInfo.where(user_id: user_id, event_date: date).first_or_create
          txs = OriginTransaction.where("DATE(event_time) = ? and user_id = ?", date, user_id)
          last_records = SpotBalanceSnapshotRecord.joins(:spot_balance_snapshot_info)
                         .where(spot_balance_snapshot_info: {user_id: user_id, event_date: info.event_date - 1.day})

          if last_records.any?
            last_records.each do |last_record|
              new_txs = txs.where(original_symbol: last_record.origin_symbol, source: last_record.source)

              update_records(info, new_txs, last_record)
            end
          end

          add_new_records(info, txs, last_records)
        end
      end
    end

    def update_records(info, txs, last_record)
      if txs.any?
        txs.group_by{|tx| [tx.original_symbol, tx.to_symbol, tx.source]}.each do |key, txs|
          from_symbol = key[0].split(key[1])[0]
          record = info.spot_balance_snapshot_records.create(origin_symbol: key[0], from_symbol: from_symbol, to_symbol: key[1], source: key[2])
          total_cost = last_record&.amount.to_f
          total_qty = last_record&.qty.to_f

          # 只有买单才会更新成本价和总金额
          txs.select{|tx| tx.trade_type == 'buy'}.each do |tx|
            total_cost += tx.amount
            total_qty += tx.qty
          end

          price = total_qty.zero? ? 0 : total_cost / total_qty

          # 卖单只更新数量和总金额
          sold_qty = txs.select{|tx| tx.trade_type == 'sell'}.sum(&:qty)
          total_qty -= sold_qty
          total_cost = total_qty * price

          record.update(price: price, qty: total_qty, amount: total_cost)
        end
      elsif last_record.present?
        record = last_record.dup
        record.spot_balance_snapshot_info_id = info.id
        record.save!
      end
    end

    def add_new_records(info, txs, last_records)
      txs.group_by { |tx| [tx.original_symbol, tx.to_symbol, tx.source] }.each do |key, txs|
        next if last_records.exists?(origin_symbol: key[0], source: key[2])
        from_symbol = key[0].split(key[1])[0]
        total_cost = 0.0
        total_qty = 0.0

        # 只有买单才会更新成本价和总金额
        txs.select{|tx| tx.trade_type == 'buy'}.each do |tx|
          total_cost += tx.amount
          total_qty += tx.qty
        end

        price = total_qty.zero? ? 0 : total_cost / total_qty

        # 卖单只更新数量和总金额
        sold_qty = txs.select{|tx| tx.trade_type == 'sell'}.sum(&:qty)
        total_qty -= sold_qty
        total_cost = total_qty * price

        info.spot_balance_snapshot_records.create(
          origin_symbol: key[0],
          from_symbol: from_symbol,
          to_symbol: key[1],
          source: key[2],
          price: price,
          qty: total_qty,
          amount: total_cost
        )
      end
    end
  end
end