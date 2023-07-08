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

      csv_data = CSV.parse(tables)
      csv_data.shift

      csv_data.each do |row|
        store_model(row)
      end

      import_status[:message] = "正在同步合约交易记录，请稍后刷新页面"
    end
    import_status
  rescue => e
    import_status[:status] = -1
    import_status[:message] = e.message
    return import_status
  end

  private

  def store_model(row)
    symbol = row[2]
    event_time = DateTime.parse(row[1])
    GetBinanceFuturesTransactionsJob.perform_later(symbol, user_id: @user_id, from_date: event_time - 1.day)
  end

  def is_valid_file?(file_name)
    %w(csv xlsx).include?(file_name.to_s.split(".").last)
  end
end