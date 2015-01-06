require "savon"
require "mundipagg/message"

module Mundipagg
  class Client
    def adapter
      @adapter ||= Savon.client do
        wsdl "https://transaction.mundipaggone.com/MundiPaggService.svc?wsdl"
        namespaces "xmlns:mun" => "http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts"
        log_level ::ActiveMerchant::Billing::Base.test? ? :debug : :error
        log true
      end
    end

    def call(operation, command, message)
      root = Mundipagg::Key.new(command, "tns").to_s
      message = Mundipagg::Message.new(message).translate

      adapter.call(operation, message: { root => message })
    end

    def manage_order(message)
      call :manage_order, :manage_order_request, message
    end

    def create_order(message)
      call :create_order, :create_order_request, message
    end
  end
end
