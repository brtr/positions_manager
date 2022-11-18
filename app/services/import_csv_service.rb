# frozen_string_literal: true

class ImportCsvService
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

      origin_count = UserPosition.count

      UserPosition.transaction do
        CSV.parse(tables).each do |row|
          store_model(row)
        end
      end

      @total_count = UserPosition.count - origin_count

      import_status[:message] = "成功导入 #{@records.count} 条仓位记录. 新增 #{@total_count}条"

      GetPrivateUserPositionsInfoJob.perform_later(user_id)
    end
    import_status
  rescue => e
    import_status[:status] = -1
    import_status[:message] = e.message
    return import_status
  end

  private

  def store_model(row)
    split_keys = ['永续', 'Perpetual']
    if split_keys.any? { |k| row[0].include?(k) }
      symbol, _ = row[0].split(' 永续')
      symbol = row[0].split(' Perpetual')[0] if symbol == row[0]
      amount, fee_symbol = row[1].split(' ')
      price = currency_to_number(row[2])
      from_symbol = symbol.split(fee_symbol)[0]
      revenue = row[4].split(' (')[0].to_f
      return unless revenue
      amount = amount.to_f
      trade_type = amount > 0 ? 'sell' : 'buy'
      amount = amount > 0 ? amount.abs - revenue : amount.abs + revenue
      qty = amount / price

      record = UserPosition.where(
        source: @source,
        origin_symbol: symbol,
        from_symbol: from_symbol,
        trade_type: trade_type,
        fee_symbol: fee_symbol,
        user_id: @user_id,
      ).first_or_create

      record.update(qty: qty.abs, price: price)

      @records.push(record)
    end
  end

  def is_valid_file?(file_name)
    %w(csv xlsx).include?(file_name.to_s.split(".").last)
  end

  def currency_to_number(currency)
    currency.gsub(',','').to_f
  end

end