module TestStubs
  def self.included(base)
    base.define_method(:setup) do
      stub_request(:get, "https://mercados.ambito.com/dolar/oficial/variacion")
        .to_return_json(body: {
          compra: "353,71",
          venta: "373,71",
          variacion: "0,58%"
        })

      stub_request(:get, "https://mercados.ambito.com/dolar/informal/variacion")
        .to_return_json(body: {
          compra: "1025,00",
          venta: "1075,00",
          variacion: "13,16%"
        })

      stub_request(:get, "https://mercados.ambito.com/dolarrava/mep/variacion")
        .to_return_json(body: {
          compra: "930,44",
          venta: "930,44",
          ultimo: "872,61",
          valor: "930,44",
          variacion: "6,60%"
        })
    end
  end
end
