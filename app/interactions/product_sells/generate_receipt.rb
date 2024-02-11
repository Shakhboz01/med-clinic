module ProductSells
  class GenerateReceipt < ActiveInteraction::Base
    include ActionView::Helpers
    include ApplicationHelper

    object :sale

    def execute
      rate = CurrencyRate.last.rate
      # calculating debt in uzs
      total_debt = (sale.buyer.calculate_debt_in_usd * rate) + sale.buyer.calculate_debt_in_uzs
      current_total_price = sale.price_in_usd ? ((sale.total_price - sale.total_paid) * rate) : sale.total_price
      debt_with_exception = total_debt - current_total_price
      items = [
        ["<b></b>", "<b></b>", "<b>Mijozning qarzdorligi:</b>", "<b>#{num_to_usd(debt_with_exception)}</b>"],
        ['', '', '', ''],
        ["<b>Tovar</b>", "<b>Soni</b>", "<b>Narxi (1 dona)</b>", "<b>Jami narx</b>"]
      ]
      sale.product_sells.each do |product_sell|
        items.push(
          [
            product_sell.pack.name,
            product_sell.amount,
            currency_convert(product_sell.price_in_usd, product_sell.sell_price),
            currency_convert(product_sell.price_in_usd, product_sell.sell_price * product_sell.amount)
          ]
        )
      end

      items.push(
        ['', '', '', ''],
        [
        '<b>Jami:</b>',
        '',
        '',
        currency_convert(sale.price_in_usd, sale.total_price)
      ])
      items.push([
        '<b>Jami to\'landi:</b>', '', '', currency_convert(sale.price_in_usd, sale.total_paid)
      ])
      items.push([
        '', '', "<b>Xariddan keyingi qarzdorlik holati:</b>", "#{num_to_usd(total_debt)}"
      ])
      r = Receipts::Receipt.new(
        title: 'AUTEX',
        font: {
          bold: File.expand_path("./app/assets/fonts/CharisSILB.ttf"),
          italic: File.expand_path("./app/assets/fonts/CharisSILB.ttf"),
          normal: File.expand_path("./app/assets/fonts/Alice-Regular.ttf")
        },
        details: [
          ["Chek nomeri:", sale.id],
          ["Sana:", sale.created_at.strftime("%D - %H:%M")],
          ["To\'lov turi:", sale.payment_type],
          ['', '']
        ],
        company: {
          name: "ALUTEX JOMBOY",
          address: "Чупон Ота дом 171",
          phone: '+99899.704.61.62',
          email: "",
          logo: File.expand_path("./app/assets/images/logo3.jpg")
        },
        recipient: [
          "<b>Mijoz</b>: #{sale.buyer.name.upcase}"
        ],
        line_items: items,
        footer: "Xaridingiz uchun raxmat. Sizni kutib qolamiz!"
      )

      r.render
      downloads_directory = File.join(Dir.home, "Downloads")
      filename = "чек-#{sale.id}-#{DateTime.current.to_i}.pdf"
      file_path = File.join(downloads_directory, filename)
      r.render_file(file_path)
      { filename: filename, file_path: file_path }
    end
  end
end
