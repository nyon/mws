require 'spec_helper'

module Mws
  class Query
    attr_reader :params
  end

  describe Query do
    let(:defaults) do
      {
        merchant: 'ABCDEFGHIJKLMN',
        access: 'ABCDEFGHIJKLMNOPQRST',
        markets: [ 'ATVPDKIKX0DER', 'KIKX0DERATVPD' ],
        last_updated_after: 4.hours.ago
      }
    end

    let(:query) {  Query.new defaults }

    it 'should default SignatureMethod to HmacSHA256' do
      query.params['SignatureMethod'].should == 'HmacSHA256'
    end

    it 'should default SignatureVersion to 2' do
      query.params['SignatureVersion'].should == '2'
    end

    it 'should default Timestamp to now in iso8601 format' do
      URI.decode(query.params['Timestamp']).should == Time.now.iso8601
    end

    it 'should accept overrides to SignatureMethod' do
      Query.new(defaults.merge(signature_method: 'HmacSHA1')).params['SignatureMethod'].should == 'HmacSHA1'
    end

    it 'should accept overrides to SignatureVersion' do
      Query.new(defaults.merge(signature_version: 3)).params['SignatureVersion'].should == '3'
    end

    it 'should accept overrides to Timestamp' do
      time = 4.hours.ago
      query = Query.new(defaults.merge(timestamp: time))
      URI.decode(query.params['Timestamp']).should == time.iso8601
    end

    it 'should translate access to AWSAccessKeyId' do
      access_key = 'ABCDEFGHIJKLMN'
      Query.new(defaults.merge(access: access_key)).params['AWSAccessKeyId'].should == access_key
    end

    it 'should translate merchant or seller to seller_id' do
      merchant = 'J4UBGSWCA31UTJ'
      queries = [ Query.new(defaults.merge(merchant: merchant)), Query.new(defaults.merge(seller: merchant)) ]
      queries.each do | query |
        query.params['SellerId'].should == merchant
      end
    end

    it 'should gracefully handle empty markets list' do
      Query.new(defaults.merge(markets: [])).params['MarketplaceIdList.Id.1'].should be nil
    end

    it 'should translate single market to MarketplaceIdList.Id.1' do
      market = 'ATVPDKIKX0DER'
      Query.new(defaults.merge(markets: [ market ])).params['MarketplaceIdList.Id.1'].should == market
    end

    it 'should translate multiple markets to MarketplaceIdList.Id.*' do
      markets = [ 'ATVPDKIKX0DER', 'KIKX0DERATVPD' ]
      query = Query.new defaults.merge(markets: markets)
      markets.each_with_index do | market, index |
        query.params["MarketplaceIdList.Id.#{index + 1}"].should == market
      end
    end

    it 'gracfully handles empty asin lists' do
      Query.new(defaults.merge(asin_list: [])).params['ASINList.ASIN.1'].should be nil
    end

    it 'translates a single asin to ASINList.ASIN.1' do
      asin = 'B002KT3XQM'
      Query.new(defaults.merge(asin_list: [ asin ])).params['ASINList.ASIN.1'].should == asin
    end

    it 'translates multiple asins to ASINList.ASIN.*' do
      asins = [ 'B002KT3XQM', 'B00FL8WW5C' ]
      query = Query.new defaults.merge(asin_list: asins)
      asins.each_with_index do | asin, index |
        query.params["ASINList.ASIN.#{index + 1}"].should == asin
      end
    end

    it 'converts multiple multi-value keys properly' do
      asins = [ 'B002KT3XQM', 'B00FL8WW5C' ]
      markets = [ 'ATVPDKIKX0DER', 'KIKX0DERATVPD' ]
      query = Query.new defaults.merge(asin_list: asins, markets: markets)

      asins.each_with_index do | asin, index |
        query.params["ASINList.ASIN.#{index + 1}"].should == asin
      end

      markets.each_with_index do | market, index |
        query.params["MarketplaceIdList.Id.#{index + 1}"].should == market
      end
    end

    it 'should sort query parameters lexicographically' do
      query.params.inject('') do | prev, entry |
        entry.first.should be > prev
        entry.first
      end
    end

    it 'should convert to a compliant query string' do
      query_string = query.to_s
      query_string.split('&').each do | entry |
        key, value = entry.split '='
        query.params[key].should == value
      end
    end
  end
end
