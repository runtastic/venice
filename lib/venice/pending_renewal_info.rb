module Venice
  class PendingRenewalInfo

    attr_reader :expiration_intent
    attr_reader :auto_renew_status
    attr_reader :auto_renew_product_id
    attr_reader :is_in_billing_retry_period
    attr_reader :product_id
    attr_reader :price_consent_status
    attr_reader :cancellation_reason


    def initialize(attributes)
      @expiration_intent = attributes['expiration_intent'].to_i unless attributes['expiration_intent'].nil?
      @auto_renew_status = attributes['auto_renew_status'].to_i unless attributes['auto_renew_status'].nil?
      @auto_renew_product_id = attributes['auto_renew_product_id']

      if attributes['is_in_billing_retry_period']
        @is_in_billing_retry_period = attributes['is_in_billing_retry_period'] == '1' ? true : false
      end

      @product_id = attributes['product_id']
      @price_consent_status = attributes['price_consent_status'].to_i unless attributes['price_consent_status'].nil?
      @cancellation_reason = attributes['cancellation_reason'].to_i unless attributes['cancellation_reason'].nil?
    end

    def to_hash
      {
        expiration_intent: @expiration_intent,
        auto_renew_status: @auto_renew_status,
        auto_renew_product_id: @auto_renew_product_id,
        is_in_billing_retry_period: @is_in_billing_retry_period,
        product_id: @product_id,
        price_consent_status: @price_consent_status,
        cancellation_reason: @cancellation_reason
      }
    end

    alias_method :to_h, :to_hash

    def to_json
      self.to_hash.to_json
    end
  end
end
