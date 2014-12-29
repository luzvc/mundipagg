require "active_support"
require "active_merchant"
require "active_merchant/billing/rails"

require "mundipagg/error"
require "mundipagg/gateway/client"
require "mundipagg/credit_card"
require "mundipagg/boleto"
require "mundipagg/refund"

require "active_merchant/billing/mundipagg_gateway"

module Mundipagg
  mattr_accessor :bank_number, :bank_code, :days_to_expire
  @@days_to_expire = 5
  @@bank_number = 341

  class << self
    def setup
      yield self
    end
  end
end
