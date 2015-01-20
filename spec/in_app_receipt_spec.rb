require 'spec_helper.rb'

describe Venice::InAppReceipt do

  describe ".new" do

    let :attributes do
      {
        "quantity" => 1,
        "product_id" => "com.foo.product1",
        "transaction_id" => "1000000070107235",
        "purchase_date" => "2014-05-28 14:47:53 Etc/GMT",
        "purchase_date_ms" => "1401288473000",
        "purchase_date_pst" => "2014-05-28 07:47:53 America/Los_Angeles",
        "original_transaction_id" => "140xxx867509",
        "original_purchase_date" => "2014-05-28 14:47:53 Etc/GMT",
        "original_purchase_date_ms" => "1401288473000",
        "original_purchase_date_pst" => "2014-05-28 07:47:53 America/Los_Angeles",
        "is_trial_period" => false,
        "version_external_identifier" => "123",
        "app_item_id" => 'com.foo.app1',
        "web_order_line_item_id" => '123456',
        "expires_date" => expires_date
      }
    end
    let(:expires_date) { "2014-06-28 07:47:53 America/Los_Angeles" }

    subject(:in_app_receipt) do
      Venice::InAppReceipt.new attributes
    end

    its(:quantity)               { 1 }
    its(:product_id)             { "com.foo.product1" }
    its(:transaction_id)         { "1000000070107235" }
    its(:purchase_date)          { should be_instance_of DateTime }
    its(:app_item_id)            { 'com.foo.app1' }
    its(:version_external_identifier) { "123" }
    its(:original)               { should be_instance_of Venice::InAppReceipt }
    its(:expires_date)           { should be_instance_of DateTime }
    its(:web_order_line_item_id) { should eq '123456' }

    it "should parse the 'original' attributes" do
      subject.original.should be_instance_of Venice::InAppReceipt
      subject.original.transaction_id.should == "140xxx867509"
      subject.original.purchase_date.should be_instance_of DateTime
    end

    it "should output a hash with attributes" do
      in_app_receipt.to_h.should include(:quantity => 1,
                                          :product_id => "com.foo.product1",
                                          :transaction_id => "1000000070107235",
                                          :purchase_date => "Wed, 28 May 2014 14:47:53 GMT",
                                          :original_purchase_date => "Wed, 28 May 2014 14:47:53 GMT"
                                        )
    end

    context "expired receipt" do
      let(:expires_date) { '2010-06-28 07:47:53' }
      its(:expired?)     { should be_true }
    end

    context "receipt has no expiration date" do
      let(:expires_date) { nil }
      its(:expired?)     { should be_false }
    end

    context "unexpired receipt" do
      let(:expires_date) { '2222-06-28' }
      its(:expired?)     { should be_false }
    end


  end

end
