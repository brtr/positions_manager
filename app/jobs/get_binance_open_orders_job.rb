class GetBinanceOpenOrdersJob < ApplicationJob
  queue_as :daily_job

  def perform
    get_position_orders
    get_spot_orders
  end

  def get_position_orders
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

      symbols = open_orders.map{|order| order['symbol']}.uniq
      OpenPositionOrder.where.not(symbol: symbols).delete_all
    end
  end

  def get_spot_orders
    open_orders = BinanceSpotsService.new.get_open_orders

    OpenSpotOrder.transaction do
      open_orders.each do |open_order|
        price = open_order[:price].to_f
        qty = open_order[:origQty].to_f
        amount = price * qty
        order = OpenSpotOrder.where(order_id: open_order[:orderId], symbol: open_order[:symbol]).first_or_initialize
        order.update(
          status: open_order[:status],
          price: price,
          orig_qty: qty,
          executed_qty: open_order[:executedQty],
          amount: amount,
          order_type: open_order[:type],
          trade_type: open_order[:side]&.downcase,
          stop_price: open_order[:stopPrice],
          order_time: Time.at(open_order[:time]/1000)
        )
      end

      symbols = open_orders.map{|order| order[:symbol]}.uniq
      OpenSpotOrder.where.not(symbol: symbols).delete_all
    end
  end
end