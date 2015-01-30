require 'net/ldap'
require 'casino/authenticator'

class CASino::LDAPAuthenticator
  DEFAULT_USERNAME_ATTRIBUTE = 'uid'

  # @param [Hash] options
  def initialize(options)
    @options = options
  end

  def validate(username, password)
    begin
      user_plain = authenticate(username, password)
      if !user_plain
        false
      else
        generate_user(user_plain)
      end
    rescue Net::LDAP::LdapError => e
      raise CASino::Authenticator::AuthenticatorError,
        "LDAP authentication failed with '#{e}'. Check your authenticator configuration."
    end
  end

  private
  def ldap
    return @ldap if @ldap
    @ldap = Net::LDAP.new
    @ldap.host = @options[:host]
    @ldap.port = @options[:port]
    if @options[:encryption]
      @ldap.encryption(@options[:encryption].to_sym)
    end
    return @ldap
  end

  def authenticate(username, password)
    unless @options[:admin_user].nil?
      ldap.auth(@options[:admin_user], @options[:admin_password])
    end
    user_plain = ldap.bind_as(:base => @options[:base], :size => 1, :password => password, :filter => user_filter(username))
    if user_plain
      include_attributes = @options[:extra_attributes].values + [username_attribute]
      user_plain = ldap.search(:base => @options[:base], :filter => user_filter(username), :attributes => include_attributes)
      if user_plain.is_a?(Array)
        user_plain = user_plain.first
      end
    end
    return user_plain
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

  def generate_user(user_plain)
    {
      username: user_plain[username_attribute].first,
      extra_attributes: extra_attributes(user_plain)
    }
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
