require 'spec_helper'

describe Venice::Receipt do
  describe "parsing the response" do
    let(:base) do
      {
        "status" => 0,
        "environment" => "Production",
        "receipt" => {
          "receipt_type"               => "Production",
          "adam_id"                    => 7654321,
          "bundle_id"                  => "com.foo.bar",
          "application_version"        => "2",
          "download_id"                => 1234567,
          "request_date"               => "2014-06-04 23:20:47 Etc/GMT",
          "request_date_ms"            => "1401924047883",
          "request_date_pst"           => "2014-06-04 16:20:47 America/Los_Angeles",
          "original_purchase_date"     => "2014-05-17 02:09:45 Etc/GMT",
          "original_purchase_date_ms"  => "1400292585000",
          "original_purchase_date_pst" => "2014-05-16 19:09:45 America/Los_Angeles",
          "original_application_version" => "1",
          "expiration_date"              => expiration_date,
        }
      }
    end
    let(:expiration_date) { nil }
    let(:in_app) do
      { "in_app" => [
        {
          "quantity"                   => "1",
          "product_id"                 => "com.foo.product1",
          "transaction_id"             => "1000000070107111",
          "original_transaction_id"    => "1000000061051111",
          "purchase_date"              => "2014-05-28 14:47:53 Etc/GMT",
          "purchase_date_ms"           => "1401288473000",
          "purchase_date_pst"          => "2014-05-28 07:47:53 America/Los_Angeles",
          "original_purchase_date"     => "2014-05-28 14:47:53 Etc/GMT",
          "original_purchase_date_ms"  => "1401288473000",
          "original_purchase_date_pst" => "2014-05-28 07:47:53 America/Los_Angeles",
          "expires_date"               => in_app_expires_date, 
          "is_trial_period"            => "false"
        }] 
      }
    end
    let(:in_app_expires_date) { "2014-06-28 14:47:53 Etc/GMT" }
    let(:latest_receipt_info) do
      {
        "latest_receipt_info"=> [
          { "quantity"=>"1",
            "product_id"=>"runtasticPRO_gold_1month_standard_rtpt1",
            "transaction_id"=>"1000000139120475",
            "original_transaction_id"=>"1000000139120475",
            "purchase_date"=>"2015-01-16 12:46:12 Etc/GMT",
            "purchase_date_ms"=>"1421412372000",
            "purchase_date_pst"=>"2015-01-16 04:46:12 America/Los_Angeles",
            "original_purchase_date"=>"2015-01-16 12:46:15 Etc/GMT",
            "original_purchase_date_ms"=>"1421412375000",
            "original_purchase_date_pst"=>"2015-01-16 04:46:15 America/Los_Angeles",
            "expires_date"=> latest_receipt_info_expires_date_1,
            "expires_date_ms"=>"1421412672000",
            "expires_date_pst"=>"2015-01-16 04:51:12 America/Los_Angeles",
            "web_order_line_item_id"=>"1000000029051371",
            "is_trial_period"=>"false"},
          { "quantity"=>"1",
            "product_id"=>"runtasticPRO_gold_1month_standard_rtpt1",
            "transaction_id"=>"1000000139121233",
            "original_transaction_id"=>"1000000139120475",
            "purchase_date"=>"2015-01-16 12:51:12 Etc/GMT",
            "purchase_date_ms"=>"1421412672000",
            "purchase_date_pst"=>"2015-01-16 04:51:12 America/Los_Angeles",
            "original_purchase_date"=>"2015-01-16 12:50:08 Etc/GMT",
            "original_purchase_date_ms"=>"1421412608000",
            "original_purchase_date_pst"=>"2015-01-16 04:50:08 America/Los_Angeles",
            "expires_date"=> latest_receipt_info_expires_date_2,
            "expires_date_ms"=>"1421412972000",
            "expires_date_pst"=>"2015-01-16 04:56:12 America/Los_Angeles",
            "web_order_line_item_id"=>"1000000029051370",
            "is_trial_period"=>"false"}
        ]
      }
    end
    let(:latest_receipt_info_expires_date_1) { "2010-01-16 12:51:12 Etc/GMT" }
    let(:latest_receipt_info_expires_date_2) { "2222-01-16 12:56:12 Etc/GMT" }
    let(:response) { base }

    subject { Venice::Receipt.new(response) }

    its(:bundle_id)              { "com.foo.bar" }
    its(:application_version)    { "2" }
    its(:in_app)                 { should eq [] }
    its(:original_purchase_date) { should be_instance_of DateTime }
    its(:expires_date)           { should be_nil}
    its(:receipt_type)           { "Production" }
    its(:adam_id)                { 7654321 }
    its(:download_id)            { 1234567 }
    its(:requested_at)           { should be_instance_of DateTime }
    its(:original_application_version) { "1" }
    its(:latest_receipt_info)    { should be_instance_of Array }
    its(:latest_receipt_info)    { should be_empty }
    its(:latest_receipt)         { should be_nil }

    context "expiration date is given" do
      let(:expiration_date) { '2014-01-01 05:03:02' }
      its(:expires_date)    { should eq DateTime.parse(expiration_date) }
    end

    context "in_app purchase is given" do
      let(:response) { base['receipt'].merge!(in_app); base }
      its(:in_app) { should be_instance_of Array }
      its(:in_app) { should_not be_empty }
    end

    context "latest_receipt_info given" do
      let(:response) do 
        base.merge(latest_receipt_info).merge(
          'latest_receipt' => 'some receipt'
        )
      end
      its(:latest_receipt_info) { should be_instance_of Array }
      its(:latest_receipt_info) { should_not be_empty }
      its(:latest_receipt)      { should eq 'some receipt' }
    end

    describe "#verify!" do

      before do
        Venice::Client.any_instance.stub(:json_response_from_verifying_data).and_return(response)
      end

      let(:receipt) { Venice::Receipt.verify("asdf") }

      it "should create the receipt" do
        receipt.should_not be_nil
      end
    end

    describe "#expired" do

      context "no expiration date given" do
        let(:expiration_date) { nil }
        its(:expired?)        { should be_false }
      end

      context "expiration date in the futue" do
        let(:expiration_date) { '2222-01-01 05:05:05' }
        its(:expired?)        { should be_false }
      end

      context "expiration date in the past" do
        let(:expiration_date) { '1990-01-01 05:05:05' }
        its(:expired?)        { should be_true }
      end

      context "no expiration date, but in_app/latest_receipt_info with expires_date" do
        let(:response) do 
          base['receipt'].merge!(in_app)
          base.merge(latest_receipt_info).merge(
            'latest_receipt' => 'some receipt'
          )
        end

        let(:expiration_date) { nil }
        let(:latest_receipt_info_expires_date_1) { "2010-01-16 12:51:12 Etc/GMT" }

        context "everything expired" do
          let(:latest_receipt_info_expires_date_2) { "2010-01-16 12:56:12 Etc/GMT" }
          let(:in_app_expires_date) { "2010-06-28 14:47:53 Etc/GMT" }
          its(:expired?)            { should be_true }
        end

        context "in_app expired, latest_receipt unexpired" do
          let(:latest_receipt_info_expires_date_2) { "2222-01-16 12:56:12 Etc/GMT" }
          let(:in_app_expires_date) { "2010-06-28 14:47:53 Etc/GMT" }
          its(:expired?)            { should be_false }
        end

        context "in_app unexpired, latest_receipt expired" do
          let(:latest_receipt_info_expires_date_2) { "2010-01-16 12:56:12 Etc/GMT" }
          let(:in_app_expires_date) { "2222-06-28 14:47:53 Etc/GMT" }
          its(:expired?)            { should be_false }
        end
      end

    end

  end
end
