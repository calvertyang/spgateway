# frozen_string_literal: true
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
require 'sinatra'
require 'spgateway'

client = Spgateway::Client.new(
  merchant_id: '123456',
  hash_key: '12345678901234567890123456789012',
  hash_iv: '1234567890123456',
  mode: :test
)

get '/mpg' do
  @client_options = client.options
  @params = client.generate_mpg_params(
    MerchantOrderNo: SecureRandom.hex(4),
    Amt: 200,
    ItemDesc: '一般交易測試',
    Email: 'hello@localhost.com',
    EmailModify: 0,
    LoginType: 0,
    CREDIT: 1
  )

  erb :mpg
end

get '/period' do
  @client_options = client.options
  @params = client.generate_credit_card_period_params(
    MerchantOrderNo: SecureRandom.hex(4),
    ProdDesc: '定期定額交易測試',
    PeriodAmt: 100,
    PeriodAmtMode: 'Total',
    PeriodType: 'M',
    PeriodPoint: '01',
    PeriodStartType: 1,
    PeriodTimes: '5'
  )

  erb :period
end

post '/validate' do
  client.verify_check_code(request.POST).to_s
end
