require "savon"
require "mundipagg/gateway/message"
require "mundipagg/gateway/key"

module Mundipagg
  module Gateway
    class Client
      attr_reader :adapter

      def initialize
        @adapter ||= Savon.client do
          wsdl "https://transaction.mundipaggone.com/MundiPaggService.svc?wsdl"
          namespaces "xmlns:mun" => "http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts"
          log_level ::ActiveMerchant::Billing::Base.test? ? :debug : :error
          log true
        end
      end

      def call(operation, command, message)
        root = Mundipagg::Gateway::Key.new(command, "tns").to_s

        adapter.call(operation, message: {
          root => Mundipagg::Gateway::Message.new(message).translate
        })
      end
    end
  end
end
