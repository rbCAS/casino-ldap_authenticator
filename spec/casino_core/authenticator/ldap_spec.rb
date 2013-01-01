require 'spec_helper'
require 'casino_core/authenticator/ldap'

describe CASinoCore::Authenticator::LDAP do
  let(:options) { {
    :host => 'localhost',
    :port => 12445,
    :base => 'dc=users,dc=example.com',
    :encryption => 'simple_tls',
    :username_attribute => 'uid',
    :extra_attributes => { :email => :mail, :fullname => :displayname }
  } }
  let(:subject) { described_class.new(options) }
  let(:connection) { Object.new }

  before(:each) do
    Net::LDAP.stub(:new).and_return(connection)
    [:host=, :port=, :encryption].each do |setting|
      connection.stub(setting)
    end
  end

  describe '#validate' do
    let(:username) { 'test' }
    let(:password) { 'foo' }
    let(:user_filter) { Net::LDAP::Filter.eq(options[:username_attribute], username) }

    before(:each) do
      connection.stub(:bind_as)
    end

    it 'does the connection setup' do
      connection.should_receive(:host=).with(options[:host])
      connection.should_receive(:port=).with(options[:port])
      connection.should_receive(:encryption).with(:"#{options[:encryption]}")
      subject.validate(username, password)
    end

    it 'calls the #bind_as method on the LDAP connection' do
      connection.should_receive(:bind_as).with(:base => options[:base], :size => 1, :password => password, :filter => user_filter)
      subject.validate(username, password)
    end

    context 'when validation succeeds' do
      let(:fullname) { 'Example User' }
      let(:email) { "#{username}@example.org" }
      let(:ldap_entry) {
        entry = Net::LDAP::Entry.new
        {:uid => username, :displayname => fullname, :mail => email}.each do |key, value|
          entry[key] = [value]
        end
        entry
      }
      before(:each) do
        connection.stub(:bind_as) do
          ldap_entry
        end
      end

      it 'returns the user data' do
        subject.validate(username, password).should == {
          username: username,
          extra_attributes: {
            :email => email,
            :fullname => fullname
          }
        }
      end
    end

    context 'when validation fails' do
      before(:each) do
        connection.stub(:bind_as) do
          false
        end
      end

      it 'returns false' do
        subject.validate(username, password).should == false
      end
    end

    context 'when communication error occurs' do
      before(:each) do
        connection.stub(:bind_as) do
          raise Net::LDAP::LdapError, 'foo'
        end
      end

      it 'raises an AuthenticatorError' do
        lambda {
          subject.validate(username, password)
        }.should raise_error(CASinoCore::Authenticator::AuthenticatorError)
      end
    end

    context 'with an admin user' do
      before(:each) do
        options.merge! :admin_user => 'admin', :admin_password => 'password'
      end

      it 'authenticates the admin user' do
        connection.should_receive(:auth).with(options[:admin_user], options[:admin_password])
        subject.validate(username, password)
      end
    end

    context 'with a filter' do
      let(:filter_expression) { '(!(attribute=abc))' }
      let(:filter) { user_filter & Net::LDAP::Filter.construct(filter_expression) }
      before(:each) do
        options.merge! :filter => filter_expression
      end

      it 'calls the #bind_as method on the LDAP connection' do
        connection.should_receive(:bind_as).with(:base => options[:base], :size => 1, :password => password, :filter => filter)
        subject.validate(username, password)
      end
    end
  end
end
