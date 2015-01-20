require 'time'

module Venice
  class Receipt
    # For detailed explanations on these keys/values, see
    # https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1

    # The app’s bundle identifier.
    attr_reader :bundle_id

    # The app’s version number.
    attr_reader :application_version

    # The receipt for an in-app purchase.
    attr_reader :in_app

    # The version of the app that was originally purchased.
    attr_reader :original_application_version

    # The original purchase date
    attr_reader :original_purchase_date

    # The date that the app receipt expires.
    attr_reader :expires_date

    # Non-Documented receipt keys/values
    attr_reader :receipt_type
    attr_reader :adam_id
    attr_reader :download_id
    attr_reader :requested_at

    attr_reader :version_external_identifier
    attr_reader :app_item_id


    attr_reader :latest_receipt
    attr_reader :latest_receipt_info

    def initialize(json = {})
      attributes                    = json['receipt']
      @bundle_id                    = attributes['bundle_id']
      @application_version          = attributes['application_version']
      @original_application_version = attributes['original_application_version']
      if attributes['original_purchase_date']
        @original_purchase_date = DateTime.parse(
          attributes['original_purchase_date']
        )
      end
      if attributes['expiration_date']
        @expires_date = DateTime.parse(attributes['expiration_date'])
      end
      if attributes['request_date']
        @requested_at = DateTime.parse(attributes['request_date'])
      end

      @receipt_type                = attributes['receipt_type']
      @adam_id                     = attributes['adam_id']
      @download_id                 = attributes['download_id']
      @version_external_identifier = attributes['version_external_identifier']
      @app_item_id                 = attributes['app_item_id']

      @in_app = if attributes['in_app']
        attributes['in_app'].map{ |attr| InAppReceipt.new(attr) }
      else
        []
      end

      @latest_receipt_info = if json['latest_receipt_info']
        json['latest_receipt_info'].map{ |lri| InAppReceipt.new(lri) }
      else
        []
      end

      @latest_receipt = json['latest_receipt']
    end

    def to_hash
      {
        bundle_id:                    @bundle_id,
        application_version:          @application_version,
        original_application_version: @original_application_version,
        original_purchase_date:       (@original_purchase_date.httpdate rescue nil),
        expires_date:                 (@expires_date.httpdate rescue nil),
        receipt_type:                 @receipt_type,
        adam_id:                      @adam_id,
        download_id:                  @download_id,
        requested_at:                 (@requested_at.httpdate rescue nil),
        version_external_identifier:  @version_external_identifier,
        app_item_id:                  @app_item_id,
        in_app:                       @in_app.map{|iap| iap.to_h },
        latest_receipt:               @latest_receipt,
        latest_receipt_info:          @latest_receipt_info.map{|lri| lri.to_h }
      }
    end
    alias_method :to_h, :to_hash

    def to_json
      self.to_hash.to_json
    end

    def expired?
      return false if expires_date && expires_date > DateTime.now
      return false if expires_date.nil? && in_app.empty? && latest_receipt_info.empty?
      return false if !in_app.empty? && in_app.any?{ |rec| !rec.expired? }
      return false if !latest_receipt_info.empty? && latest_receipt_info.any?{ |rec| !rec.expired? }
      true
    end


    class << self
      def verify(data, options = {})
        verify!(data, options) rescue false
      end

      def verify!(data, options = {})
        client = Client.production

        begin
          client.verify!(data, options)
        rescue VerificationError => error
          case error.code
          when 21007
            client = Client.development
            retry
          when 21008
            client = Client.production
            retry
          else
            raise error
          end
        end
      end

      alias :validate :verify
      alias :validate! :verify!
    end

    class VerificationError < StandardError
      attr_accessor :code
      attr_accessor :receipt

      def initialize(code, receipt)
        @code = Integer(code)
        @receipt = receipt
      end

      def message
        case @code
          when 21000
            "The App Store could not read the JSON object you provided."
          when 21002
            "The data in the receipt-data property was malformed."
          when 21003
            "The receipt could not be authenticated."
          when 21004
            "The shared secret you provided does not match the shared secret on file for your account."
          when 21005
            "The receipt server is not currently available."
          when 21006
            "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response."
          when 21007
            "This receipt is a sandbox receipt, but it was sent to the production service for verification."
          when 21008
            "This receipt is a production receipt, but it was sent to the sandbox service for verification."
          else
            "Unknown Error: #{@code}"
        end
      end
    end
  end
end
