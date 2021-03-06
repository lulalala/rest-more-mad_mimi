require 'rest-core'
require 'crack/xml'

module RestCore
  MadMimi = Builder.client(:data, :username, :api_key, :promotion_name) do
    use Timeout       , 300
    use DefaultSite   , 'https://api.madmimi.com/'
    use DefaultQuery  , {}
    use Cache         , {}, 60 do
      use ErrorHandler, lambda { |env| MadMimi::Error.call(env) }
      use ErrorDetectorHttp
    end
    use Defaults      , :data => {}
  end
end

class RestCore::MadMimi::Error < RestCore::Error
  include RestCore
  attr_reader :error, :code, :url
  def initialize error, code, url=''
    @error, @code, @url = error, code, url
    super("[#{code}] #{error.inspect} from #{url}")
  end

  def self.call env
    error, code, url = env[RESPONSE_BODY], env[RESPONSE_STATUS],
                       Middleware.request_uri(env)
    new(error, code, url)
  end
end

require 'rest-core/client/mad_mimi/audience_list'

module RestCore::MadMimi::Client
  include RestCore

  POSSIBLE_STATUSES = %w[ignorant sending failed sent received clicked_through
                         bounced retried retry_failed forwarded opted_out
                         abused]

  # https://madmimi.com/developer/mailer/transactional
  #
  # Usage:
  #
  #   client.mailer('ayaya@example.com',
  #                 :subject => 'Subject',
  #                 :raw_html => 'the mail body [[tracking_beacon]]')
  #
  # The transaction code is convert to integer
  def mailer(recipient, options = {})
    options = {:recipients => recipient}.merge(options)
    response = post('mailer', options)
    # response was a string that included RestClient::AbstractResponse,
    # and it overrided #to_i method (which returns status code)
    String.new(response).to_i
  end

  # https://madmimi.com/developer/mailer/send-to-a-list
  #
  # Usage:
  #
  #   client.mailer_to_list('list_name',
  #                         :subject => 'Subject',
  #                         :raw_html => 'the mail body [[tracking_beacon]]')
  #
  # The transaction code is convert to integer
  def mailer_to_list(list, options = {})
    list = list.join(',') if list.is_a?(Array)
    options = {:list_name => list}.merge(options)
    response = post('mailer/to_list', options)
    # response was a string that included RestClient::AbstractResponse,
    # and it overrided #to_i method (which returns status code)
    String.new(response).to_i
  end

  # https://madmimi.com/developer/mailer/status
  #
  # Usage:
  #
  #   id = client.mailer(...)
  #   client.status(id)
  def status(id)
    get("mailers/status/#{id.to_i}")
  end

  # https://madmimi.com/developer/lists
  # Audience lists apis

  def audience_lists
    response = get('audience_lists/lists.xml')
    Crack::XML.parse(response.body)['lists']['list'].map do |list|
      RestCore::MadMimi::AudienceList.new(self, list)
    end
  end

  def create_audience_list(name)
    post('audience_lists', :name => name).tap{}
    RestCore::MadMimi::AudienceList.new(self, :name => name)
  end

  def rename_audience_list(name, new_name)
    post("audience_lists/#{CGI.escape(name)}/rename", :name => new_name).tap{}
    RestCore::MadMimi::AudienceList.new(self, :name => new_name)
  end

  def destroy_audience_list(name)
    post("audience_lists/#{CGI.escape(name)}", :_method => 'delete').tap{}
  end

  # https://madmimi.com/developer/lists
  # Audience lists apis (members)

  def add_member_to_audience_list(list, email, options = {})
    options = {:email => email}.merge(options)
    post("audience_lists/#{CGI.escape(list)}/add", options).tap{}
  end

  def remove_member_from_audience_list(list, email, options = {})
    options = {:email => email}.merge(options)
    post("audience_lists/#{CGI.escape(list)}/remove", options).tap{}
  end

  def query
    {'username' => username,
     'api_key' => api_key,
     'promotion_name' => promotion_name}
  end
end

class RestCore::MadMimi
  include RestCore::MadMimi::Client
end
