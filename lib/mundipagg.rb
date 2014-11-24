require "active_support"
require "active_model"
require "mundipagg/gateway/client"
require "mundipagg/buyer"
require "mundipagg/order"
require "mundipagg/transaction/boleto"

module Mundipagg
  mattr_accessor :merchant_key, :bank_number, :bank_code, :days_to_expire, :env
  @@env = :test
  @@days_to_expire = 5
  @@bank_number = 341

  class << self
    def setup
      yield self
    end

    def test?
      env == :test
    end
  end
end
