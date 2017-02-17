# encoding: utf-8
require File.expand_path('../test_helper', __FILE__)

class TestSpgateway < MiniTest::Test
  def setup
    @client = Spgateway::Client.new({
      merchant_id: '123456',
      hash_key: '12345678901234567890123456789012',
      hash_iv: '1234567890123456',
      mode: :test
    })
  end

  def test_raise_invalid_mode_error
    assert_raises Spgateway::InvalidMode do
      Spgateway::Client.new(mode: :invalid)
    end
  end

  def test_raise_missing_option_error
    assert_raises Spgateway::MissingOption do
      Spgateway::Client.new
    end
  end

  def test_raise_missing_parameter_error
    assert_raises Spgateway::MissingParameter do
      @client.generate_mpg_params
    end
  end

  def test_raise_unsupported_type_error
    assert_raises Spgateway::UnsupportedType do
      @client.make_check_value :wrong_type
    end
  end

  def test_encoding_post_data_1
    data = 'abcdefghijklmnop'
    encrypted = @client.encode_post_data data
    assert_equal 'b91d3ece42c203729b38ae004e96efb9b64c41eeb074cad7ebafa3973181d233', encrypted
  end

  def test_encoding_post_data_2
    data = 'abcdefghijklmnopqrstuvwxyzABCDEF'
    encrypted = @client.encode_post_data data
    assert_equal 'b91d3ece42c203729b38ae004e96efb90109ee25f7861b6bb33891be88d9a799484f0d3ccee9a094e9fad6d51db716ff2df7a5137639aaf94fba4f309e2af173', encrypted
  end

  def test_mpg_check_value
    check_value = @client.make_check_value :mpg,
      MerchantID: @client.options[:merchant_id],
      TimeStamp: '1451577600',
      Version: '1.1',
      MerchantOrderNo: '20160101001',
      Amt: 100

    assert_equal 'C3D5EABA60966C1206E95FEBB0A8023FB14562A78E2793EBBAD449885F31D8F5', check_value
  end

  def test_query_trade_info_check_value
    check_value = @client.make_check_value :query_trade_info,
      MerchantID: @client.options[:merchant_id],
      MerchantOrderNo: '20160101001',
      Amt: 100

    assert_equal 'E7D095C909A78C57F259EADFAFF6BBEF3F6C0277C52F3EA753B7FF71A8205D38', check_value
  end

  def test_credit_card_period_check_value
    check_value = @client.make_check_value :credit_card_period,
      MerchantID: @client.options[:merchant_id],
      MerchantOrderNo: '20160101001',
      PeriodAmt: 100,
      PeriodType: 'M',
      TimeStamp: '1451577600'

    assert_equal 'C3D59CD4B97AABB9CF49790D41EBD039DC22C9C9B315976FF85021D80D08DB8E', check_value
  end

  def test_generate_mpg_params
    result = @client.generate_mpg_params({
      MerchantOrderNo: '20160101001',
      Amt: 100,
      ItemDesc: '一般交易測試',
      Email: 'hello@localhost.com',
      LoginType: 0,
      TimeStamp: '1451577600'
    })

    expected_result = {
      RespondType: 'String',
      TimeStamp: '1451577600',
      Version: '1.2',
      MerchantOrderNo: '20160101001',
      Amt: 100,
      ItemDesc: '一般交易測試',
      Email: 'hello@localhost.com',
      LoginType: 0,
      MerchantID: '123456',
      CheckValue: 'DCCBB09E7E5E95F7778C624E94AF60713F0EDE4A06811754E15B41F61E52502E'
    }

    assert_equal expected_result, result
  end

  def test_query_trade_info
    skip 'test this if there is public sandbox'
    result = @client.query_trade_info({
      MerchantOrderNo: 'a465e094',
      Amt: 100
    })

    assert_equal true, @client.verify_check_code(result)
  end

  def test_credit_card_deauthorize
    skip 'test this if there is public sandbox'
    result = @client.credit_card_deauthorize({
      MerchantOrderNo: '4e19cab1',
      Amt: 100,
      IndexType: 1
    })

    assert_equal true, @client.verify_check_code(result)
  end

  def test_credit_card_deauthorize_by_merchant_order_no
    skip 'test this if there is public sandbox'
    result = @client.credit_card_deauthorize_by_merchant_order_no({
      MerchantOrderNo: '4e19cab1',
      Amt: 100
    })

    assert_equal true, @client.verify_check_code(result)
  end

  def test_credit_card_deauthorize_by_trade_no
    skip 'test this if there is public sandbox'
    result = @client.credit_card_deauthorize_by_trade_no({
      TradeNo: '16010112345678901',
      Amt: 100
    })

    assert_equal true, @client.verify_check_code(result)
  end

  def test_credit_card_collect_refund
    skip 'test this if there is public sandbox'
    result = @client.credit_card_collect_refund({
      MerchantOrderNo: '4e19cab1',
      Amt: 100,
      CloseType: 2,
      IndexType: 1
    })

    assert_equal 'SUCCESS', result['Status']
  end

  def test_credit_card_collect_refund_by_merchant_order_no
    skip 'test this if there is public sandbox'
    result = @client.credit_card_collect_refund_by_merchant_order_no({
      MerchantOrderNo: '4e19cab1',
      Amt: 100,
      CloseType: 2
    })

    assert_equal 'SUCCESS', result['Status']
  end

  def test_credit_card_collect_refund_by_trade_no
    skip 'test this if there is public sandbox'
    result = @client.credit_card_collect_refund_by_trade_no({
      TradeNo: '16010112345678901',
      Amt: 100,
      CloseType: 2
    })

    assert_equal 'SUCCESS', result['Status']
  end

  def test_generate_credit_card_period_params
    result = @client.generate_credit_card_period_params({
      MerchantOrderNo: '4e19cab1',
      ProdDesc: '定期定額交易測試',
      PeriodAmt: 100,
      PeriodAmtMode: 'Total',
      PeriodType: 'M',
      PeriodPoint: '01',
      PeriodStartType: 1,
      PeriodTimes: '5',
      TimeStamp: '1451577600'
    })

    expected_result = {
      RespondType: 'String',
      TimeStamp: '1451577600',
      Version: '1.0',
      MerchantOrderNo: '4e19cab1',
      ProdDesc: '定期定額交易測試',
      PeriodAmt: 100,
      PeriodAmtMode: 'Total',
      PeriodType: 'M',
      PeriodPoint: '01',
      PeriodStartType: 1,
      PeriodTimes: '5',
      MerchantID: '123456',
      CheckValue: '6CFD64AF2A94723AFAFF6BD86B531A98C2C79582FB68C587D931CF4750F4E535'
    }

    assert_equal expected_result, result
  end

  def test_check_code_valid?
    response_hash = {
      Status: 'SUCCESS',
      Message: '查詢成功',
      Result: nil,
      MerchantID: '123456',
      Amt: '100',
      TradeNo: '16010112345678901',
      MerchantOrderNo: '4e19cab1',
      TradeStatus: '1',
      PaymentType: 'CREDIT',
      CreateTime: '2016-01-01+00:00:00',
      PayTime: '2016-01-01+00:00:01',
      FundTime: '0000-00-00',
      CheckCode: 'FD6E9A29DF1FA442EA1C6A20701A289C36565D445D29B6E063DAE62C75B709D1',
      RespondCode: '00',
      Auth: '987654',
      CloseStatus: '0',
      BackStatus: '0',
      RespondMsg: '授權成功',
      Inst: '0',
      InstFirst: '100',
      InstEach: '0',
      Bonus: '0',
      RedAmt: '0'
    }
    result = @client.verify_check_code response_hash

    assert_equal true, result
  end
end
