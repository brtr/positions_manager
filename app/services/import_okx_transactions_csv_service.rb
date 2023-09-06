# frozen_string_literal: true

class ImportOkxTransactionsCsvService
  attr_reader :files, :source, :user_id
  require "csv"

  def initialize(files, source, user_id)
    @files = files
    @source = source.downcase
    @user_id = user_id
    @total_count = 0
    @okx_records = []
  end

  def call
    import_status = {
      status: 1,
      message: "Has unknow errors"
    }

    if !is_valid_file?
      import_status[:status] = -1
      import_status[:message] = "仅支持csv 和 xlxs 两种格式的文件"
    else
      options = {
        headers: true,
        encoding: 'utf-8'
      }

      @files.each do |file|
        tables = File.read(file).gsub!("\r", '')
        generate_records(tables)
      end

      store_okx_model

      import_status[:message] = "正在同步合约交易记录，请稍后刷新页面"
    end
    import_status
  rescue => e
    import_status[:status] = -1
    import_status[:message] = e.message
    return import_status
  end

  private
  def generate_records(tables)
    CSV.parse(tables, headers: true, row_sep: :auto).each_with_index do |row, idx|
      next if row[2] == "币币" || row[3] == "币币"
      @okx_records.push(row)
    end
  end

  def store_okx_model
    SyncedTransaction.transaction do
      @okx_records.each do |row|
        if row.count == 15
          next unless row[14] == "完全成交"
          other_row = @okx_records.select{|r| r[0] == row[0] && r.count == 12}.first
          order_id = other_row[1].to_f.zero? ? other_row[0] : other_row[1]
          symbol = row[3]
          event_time = DateTime.parse(row[1])
          amount = other_row[8].to_f
          price = symbol == 'ELON-USDT-SWAP' ? row[11].to_f : other_row[7].to_f
          qty = amount / price
          revenue = row[12].to_f
          trade_type = ["卖", "SELL", "平空"].include?(row[5]) ? "sell" : "buy"
          fee, fee_symbol = row[13].split(' ')
          fee = fee.to_f.abs
          position_side = if trade_type == 'sell'
                            revenue == 0 ? 'short' : 'long'
                          else
                            revenue == 0 ? 'long' : 'short'
                          end

          tx = SyncedTransaction.where(
                order_id: order_id,
                source: @source,
                user_id: @user_id,
                origin_symbol: symbol,
                qty: qty,
                trade_type: trade_type
              ).first_or_create

          tx.update(
            event_time: event_time,
            price: price,
            amount: amount,
            fee: fee,
            revenue: revenue,
            fee_symbol: fee_symbol
          )
        end
      end
    end
  end

  def is_valid_file?
    @files.each do |file|
      %w(csv xlsx).include?(file.original_filename.to_s.split(".").last)
    end
  end
end