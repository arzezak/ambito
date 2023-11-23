module TestStubs
  def self.included(base)
    base.define_method(:setup) do
      stub_ambito_request to: "dolar/oficial", with: json("oficial")
      stub_ambito_request to: "dolar/informal", with: json("informal")
      stub_ambito_request to: "dolarrava/mep", with: json("mep")
      stub_ambito_request to: "dolarcripto", with: json("cripto")
    end
  end

  private

  def json(fixture)
    {body: JSON.parse(File.read("./test/fixtures/#{fixture}.json"))}
  end

  def stub_ambito_request(to:, with:)
    stub_request(:get, url(to)).to_return_json(with)
  end

  def url(dolar)
    "https://mercados.ambito.com/#{dolar}/variacion"
  end
end
