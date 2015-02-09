require 'net/ldap'
require 'casino/authenticator'

class CASino::LDAPAuthenticator
  DEFAULT_USERNAME_ATTRIBUTE = 'uid'

  # @param [Hash] options
  def initialize(options)
    @options = options
  end

  def validate(username, password)
    authenticate(username, password)
  rescue Net::LDAP::LdapError => e
    raise CASino::Authenticator::AuthenticatorError,
      "LDAP authentication failed with '#{e}'. Check your authenticator configuration."
  end

  def load_user_data(username)
    load_user_data_with_connection(username, connect_to_ldap)
  end

  private
  def connect_to_ldap
    Net::LDAP.new.tap do |ldap|
      ldap.host = @options[:host]
      ldap.port = @options[:port]
      if @options[:encryption]
        ldap.encryption(@options[:encryption].to_sym)
      end
      unless @options[:admin_user].nil?
        ldap.auth(@options[:admin_user], @options[:admin_password])
      end
    end
  end

  def authenticate(username, password)
    # Don't allow "Unauthenticated bind" (http://www.openldap.org/doc/admin24/security.html#Authentication%20Methods)
    return false unless password && !password.empty?

    ldap = connect_to_ldap
    user = ldap.bind_as(:base => @options[:base], :size => 1, :password => password, :filter => user_filter(username))
    if user
      load_user_data_with_connection(username, ldap)
    else
      false
    end
  end

  def load_user_data_with_connection(username, ldap)
    include_attributes = @options[:extra_attributes].values + [username_attribute]
    user = ldap.search(:base => @options[:base], :filter => user_filter(username), :attributes => include_attributes)
    return nil if user.nil?
    if user.is_a?(Array)
      user = user.first
    end
    user_data(user)
  end

  def user_data(user)
    {
      username: user[username_attribute].first,
      extra_attributes: extra_attributes(user)
    }
  end

  def username_attribute
    @options[:username_attribute] || DEFAULT_USERNAME_ATTRIBUTE
  end

  def user_filter(username)
    filter = Net::LDAP::Filter.eq(username_attribute, username)
    unless @options[:filter].nil?
      filter &= Net::LDAP::Filter.construct(@options[:filter])
    end
    filter
  end

  def extra_attributes(user_plain)
    if @options[:extra_attributes]
      result = {}
      @options[:extra_attributes].each do |index_result, index_ldap|
        value = user_plain[index_ldap]
        if value
          result[index_result] = "#{value.first}"
        end
      end
      result
    else
      nil
    end
  end
end
