module Mundipagg
  class Order
    include ActiveModel::Model

    attr_accessor :id, :transaction
    validates :id, :transaction, presence: true

    def transaction=(transaction)
      transaction.order_id = id
      @transaction = transaction
    end

    def create
      client = Mundipagg::Gateway::Client.new
      client.call(:create_order, :create_order_request, to_message)
    end

    def to_message
      {
        amount_in_cents: transaction.amount,
        currency_iso_enum: "BRL",
        merchant_key: Mundipagg.merchant_key
      }.merge(transaction.to_message)
    end
  end
end
