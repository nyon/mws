require 'spec_helper'

module Mws::Apis
  describe Products do
    defaults = {
      merchant: 'ABCDEFGHIJKLMN',
      access: 'ABCDEFGHIJKLMNOPQRST',
      secret: '1234567890123456789012345678901234567890'
    }

    connection = Mws.connect defaults
    products = connection.products

    describe '#status' do
      it 'returns a status code' do
        expect(['GREEN', 'YELLOW', 'RED']).to include products.status market: 'ATVPDKIKX0DER'
      end
    end

    describe '#list_matching_products' do
      it 'requires an AWS access key id' do
        expect {
          products.list_matching_products
        }.to raise_error Mws::Errors::ServerError, 'The AWS Access Key Id you provided does not exist in our records.'
      end
    end

    describe '#get_competitive_pricing_for_sku' do
      it 'requires an AWS access key id' do
        expect {
          products.get_competitive_pricing_for_sku
        }.to raise_error Mws::Errors::ServerError, 'The AWS Access Key Id you provided does not exist in our records.'
      end
    end

    describe '#get_competitive_pricing_for_asin' do
      it 'requires an AWS access key id' do
        expect {
          products.get_competitive_pricing_for_asin
        }.to raise_error Mws::Errors::ServerError, 'The AWS Access Key Id you provided does not exist in our records.'
      end
    end

    describe '#get_product_categories_for_asin' do
      it 'requires an AWS access key id' do
        expect {
          products.get_product_categories_for_asin
        }.to raise_error Mws::Errors::ServerError, 'The AWS Access Key Id you provided does not exist in our records.'
      end
    end
  end
end
