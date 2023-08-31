class GetWalletHistoriesJob < ApplicationJob
  queue_as :daily_job

  def perform
    deposit_histories = BinanceSpotsService.new.deposit_histories
    generate_histories(deposit_histories, :deposit)

    withdraw_histories = BinanceSpotsService.new.withdraw_histories
    generate_histories(withdraw_histories, :withdraw)
  end

  def generate_histories(data, trade_type)
    WalletHistory.transaction do
      data.each do |d|
        if trade_type == :deposit
          apply_time = complete_time = Time.at(d[:insertTime] / 1000)
          is_completed = d[:status] == 1
        else
          apply_time = d[:applyTime]
          complete_time = d[:completeTime]
          is_completed = d[:status] == 6
        end

        h = WalletHistory.where(trade_type: trade_type, order_no: d[:id], symbol: d[:coin], apply_time: apply_time).first_or_create
        h.update(
          is_completed: is_completed,
          amount: d[:amount].to_f,
          transfer_type: d[:transferType],
          fee: d[:transactionFee].to_f,
          network: d[:network],
          complete_time: complete_time
        )
      end
    end
  end
end