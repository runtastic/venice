require 'spec_helper'

describe Venice::Client do
  let(:receipt_data) { "asdfzxcvjklqwer" }
  let(:client) { subject }

  describe "#verify!" do
    context "no shared_secret" do
      before do
        client.shared_secret = nil
        Venice::Receipt.stub :new
      end

      it "should only include the receipt_data" do
        Net::HTTP.any_instance.should_receive(:request) do |post|
          post.body.should eq({'receipt-data' => receipt_data}.to_json)
          post
        end
        client.verify! receipt_data
      end
    end

    context "with a shared secret" do
      let(:secret) { "shhhhhh" }

      before do
        Venice::Receipt.stub :new
      end

      it "should include the secret in the post" do
        Net::HTTP.any_instance.should_receive(:request) do |post|
          post.body.should eq({'receipt-data' => receipt_data, 'password' => secret}.to_json)
          post
        end
        client.verify!(receipt_data, { shared_secret: secret })
      end
    end

    context "with a latest receipt info attribute" do
      before do
        client.stub(:json_response_from_verifying_data).and_return(response)
      end
      let(:latest_receipt) { "<encoded string>" }

      let(:response) do
        {"status"=>0,
         "environment"=>"Sandbox",
         "receipt"=>
          {"receipt_type"=>"ProductionSandbox",
           "adam_id"=>0,
           "app_item_id"=>0,
           "bundle_id"=>"at.runtastic.runtastic.pro",
           "application_version"=>"5.6",
           "download_id"=>0,
           "version_external_identifier"=>0,
           "request_date"=>"2015-01-19 09:09:44 Etc/GMT",
           "request_date_ms"=>"1421658584066",
           "request_date_pst"=>"2015-01-19 01:09:44 America/Los_Angeles",
           "original_purchase_date"=>"2013-08-01 07:00:00 Etc/GMT",
           "original_purchase_date_ms"=>"1375340400000",
           "original_purchase_date_pst"=>"2013-08-01 00:00:00 America/Los_Angeles",
           "original_application_version"=>"1.0",
           "in_app"=>
            [{"quantity"=>"1",
              "product_id"=>"runtasticPRO_gold_1month_standard_rtpt1",
              "transaction_id"=>"1000000139120475",
              "original_transaction_id"=>"1000000139120475",
              "purchase_date"=>"2015-01-16 12:46:12 Etc/GMT",
              "purchase_date_ms"=>"1421412372000",
              "purchase_date_pst"=>"2015-01-16 04:46:12 America/Los_Angeles",
              "original_purchase_date"=>"2015-01-16 12:46:15 Etc/GMT",
              "original_purchase_date_ms"=>"1421412375000",
              "original_purchase_date_pst"=>"2015-01-16 04:46:15 America/Los_Angeles",
              "expires_date"=>"2015-01-16 12:51:12 Etc/GMT",
              "expires_date_ms"=>"1421412672000",
              "expires_date_pst"=>"2015-01-16 04:51:12 America/Los_Angeles",
              "web_order_line_item_id"=>"1000000029051371",
              "is_trial_period"=>"false"
            }]
          },
         "latest_receipt_info"=>
          [{"quantity"=>"1",
            "product_id"=>"runtasticPRO_gold_1month_standard_rtpt1",
            "transaction_id"=>"1000000139120475",
            "original_transaction_id"=>"1000000139120475",
            "purchase_date"=>"2015-01-16 12:46:12 Etc/GMT",
            "purchase_date_ms"=>"1421412372000",
            "purchase_date_pst"=>"2015-01-16 04:46:12 America/Los_Angeles",
            "original_purchase_date"=>"2015-01-16 12:46:15 Etc/GMT",
            "original_purchase_date_ms"=>"1421412375000",
            "original_purchase_date_pst"=>"2015-01-16 04:46:15 America/Los_Angeles",
            "expires_date"=>"2015-01-16 12:51:12 Etc/GMT",
            "expires_date_ms"=>"1421412672000",
            "expires_date_pst"=>"2015-01-16 04:51:12 America/Los_Angeles",
            "web_order_line_item_id"=>"1000000029051371",
            "is_trial_period"=>"false"},
           {"quantity"=>"1",
            "product_id"=>"runtasticPRO_gold_1month_standard_rtpt1",
            "transaction_id"=>"1000000139121233",
            "original_transaction_id"=>"1000000139120475",
            "purchase_date"=>"2015-01-16 12:51:12 Etc/GMT",
            "purchase_date_ms"=>"1421412672000",
            "purchase_date_pst"=>"2015-01-16 04:51:12 America/Los_Angeles",
            "original_purchase_date"=>"2015-01-16 12:50:08 Etc/GMT",
            "original_purchase_date_ms"=>"1421412608000",
            "original_purchase_date_pst"=>"2015-01-16 04:50:08 America/Los_Angeles",
            "expires_date"=>"2015-01-16 12:56:12 Etc/GMT",
            "expires_date_ms"=>"1421412972000",
            "expires_date_pst"=>"2015-01-16 04:56:12 America/Los_Angeles",
            "web_order_line_item_id"=>"1000000029051370",
            "is_trial_period"=>"false"}
          ],
         "latest_receipt"=> latest_receipt
        }
      end


      it "should create a latest receipt" do
        receipt = client.verify! 'asdf'
        expect(receipt.latest_receipt).to eq latest_receipt
      end

      it "should create a latest receipt info" do
        receipt = client.verify! 'asdf'
        expect(receipt.latest_receipt_info.count).to eq 2
      end
    end

  end
end
