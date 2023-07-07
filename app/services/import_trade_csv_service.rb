# frozen_string_literal: true

class ImportTradeCsvService
  attr_reader :file, :source, :user_id
  require "csv"

  def initialize(file, source, user_id)
    @file = file
    @source = source.downcase
    @user_id = user_id
    @total_count = 0
    @records = []
  end

  def call
    import_status = {
      status: 1,
      message: "Has unknow errors"
    }
    file_name = @file.original_filename

    if !is_valid_file?(file_name)
      import_status[:status] = -1
      import_status[:message] = "仅支持csv 和 xlxs 两种格式的文件"
    else
      options = {
        headers: true,
        encoding: 'utf-8'
      }
      begin
        if file_name.include?(".csv")
          tables = File.read(@file)
        else
          xlsx = Roo::Spreadsheet.open(@file)
          sheet = xlsx.sheet(0)
          tables = sheet.to_csv
        end
      rescue CSV::MalformedCSVError
        options[:encoding] = "windows-1251:utf-8"
        tables = File.read(@file, options)
      end

      origin_count = SyncedTransaction.count

      csv_data = CSV.parse(tables)
      csv_data.shift

      SyncedTransaction.transaction do
        csv_data.each do |row|
          store_model(row)
        end
      end

      @total_count = SyncedTransaction.count - origin_count

      import_status[:message] = "成功导入 #{@records.count} 条合约交易记录. 新增 #{@total_count}条"
    end
    import_status
  rescue => e
    import_status[:status] = -1
    import_status[:message] = e.message
    return import_status
  end

  private

  def store_model(row)
    trade_type = row[3].downcase
    revenue = row[8].to_f
    position_side = if trade_type == 'sell'
      revenue == 0 ? 'short' : 'long'
    else
      revenue == 0 ? 'long' : 'short'
    end
    fee, fee_symbol = row[7].split(' ')
    tx = SyncedTransaction.where(user_id: @user_id, event_time: DateTime.parse(row[1])).first_or_create
    tx.update(
      source: 'binance',
      origin_symbol: row[2],
      fee_symbol: fee_symbol,
      trade_type: trade_type,
      price: row[4],
      qty: get_number(row[5].to_f, revenue),
      amount: get_number(row[6].to_f, revenue),
      fee: fee,
      revenue: revenue,
      position_side: position_side
    )

    @records.push(tx)
  end

  def is_valid_file?(file_name)
    %w(csv xlsx).include?(file_name.to_s.split(".").last)
  end

  def get_number(num, revenue)
    revenue == 0 || num == 0 ? num : num * -1
  end
end