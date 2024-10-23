module ProductSells
  class FindAverageSellAndBuyPrice < ActiveInteraction::Base
    hash :price_data, strip: false
    boolean :price_in_usd, default: true
    decimal :rate, default: CurrencyRate.last.rate

    def execute
      total_sell_price = 0
      total_buy_price = 0
      total_amount = 0

      price_data.each do |id, data|
        next if data['amount'].to_i.zero?

        amount = data["amount"].to_i
        sell_price = data["sell_price"].to_f
        buy_price = data["buy_price"].to_f

        total_sell_price += sell_price * amount
        total_buy_price += buy_price * amount
        total_amount += amount
      end

      average_sell_price = total_sell_price / total_amount
      average_buy_price = total_buy_price / total_amount
      if price_in_usd
        sell_price_in_uzs = average_sell_price * rate
        buy_price_in_uzs = average_buy_price * rate
        sell_price_in_usd = average_sell_price
        buy_price_in_usd = average_buy_price
      else
        sell_price_in_usd = average_sell_price / rate
        buy_price_in_usd = average_buy_price / rate
        sell_price_in_uzs = average_sell_price
        buy_price_in_uzs = average_buy_price
      end

      sell_price_in_uzs = ProductSells::RoundPrice.run(number: sell_price_in_uzs).result
      buy_price_in_uzs = ProductSells::RoundPrice.run(number: buy_price_in_uzs).result

      return {
               average_prices: {
                 average_sell_price_in_usd: sell_price_in_usd,
                 average_buy_price_in_usd: buy_price_in_usd,
                 average_buy_price_in_uzs: buy_price_in_uzs,
                 average_sell_price_in_uzs: sell_price_in_uzs,
               },
               price_data: price_data,
               price_in_usd: price_in_usd
             }
    end
  end
end
