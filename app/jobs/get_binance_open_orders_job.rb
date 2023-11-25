class GetBinanceOpenOrdersJob < ApplicationJob
  queue_as :daily_job

  def perform
    open_orders = BinanceFuturesService.new.get_pending_orders

    OpenPositionOrder.transaction do
      open_orders.each do |open_order|
        price = open_order['price'].to_f
        qty = open_order['origQty'].to_f
        amount = price * qty
        order = OpenPositionOrder.where(order_id: open_order['orderId'], symbol: open_order['symbol']).first_or_initialize
        order.update(
          status: open_order['status'],
          price: price,
          orig_qty: qty,
          amount: amount,
          order_type: open_order['type'],
          trade_type: open_order['side'].downcase,
          position_side: open_order['positionSide'].downcase,
          stop_price: open_order['stopPrice'],
          order_time: Time.at(open_order['time']/1000)
        )
      end

      symbols = open_orders.map{|order| order['symbol']}
      OpenPositionOrder.where.not(symbol: symbols).delete_all
    end
  end
end