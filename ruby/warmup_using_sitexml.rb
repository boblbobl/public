#
# Warmup script using sitemap.xml as source
#

require 'net/http'
require 'uri'
require 'rexml/document'
require 'pony'

# NOTE: On Windows install 'windows-pr' 'win32console' gems for colour output
require 'rainbow'

#
# Settings
#
settings = { :url => 'http://www.cityofsydney.nsw.gov.au/sitemap.xml',
             :mail_to => 'user@domain.local',
             :mail_from => 'user2@domain.local',
             :mail_server => 'localhost',
             :mail_port => '25',
             :mail_domain => 'domain.local', # the HELO domain provided by the client to the server
             :mail_user => 'user',
             :mail_password => 'password',
             :mail_auth => 'plain' # :plain, :login, :cram_md5, no auth by default
}

# http_get method
def http_get(uri)
  uri = URI.parse(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
end

# Parse sitemap.xml file
response = http_get(settings[:url])
doc = REXML::Document.new(response.body)

# Init page sizes and error array
urls = doc.root.size
error_pages = []
u = 0

# Parse URLs and output results
doc.elements.each('urlset/url/loc') {
    |e| http_get(e.text)
    u += 1
    if response.code.to_i == 200
      print "[#{u}/#{urls}] ".foreground(:cyan)
      print "#{response.code} ".foreground(:green)
      puts "#{e.text}".foreground(:white)
      error_pages << e.text
    else
      print "[#{u}/#{urls}] ".foreground(:red).inverse
      print "#{response.code} ".foreground(:red).inverse
      puts "#{e.text}".foreground(:red).inverse
      error_pages << e.text
    end
}

# Add erroneous pages to error_pages array
html_body_text = ''
error_pages.each { |page| html_body_text << "<li><a href=\"#{page}\">#{page}</a></li>" }

# Send errors pages via SMTP
Pony.mail(:to => settings[:mail_to], :via => :smtp, :via_options => {
            :address              => settings[:mail_server],
            :port                 => settings[:mail_port],
            #:user_name            => settings[:mail_user],
            #:password             => settings[:mail_password],
            #:authentication       => setttings[:mail_auth],
            :domain               => settings[:mail_domain]
          },
          :from => settings[:mail_from],
          :subject => 'Pages with Errors',
          :body => 'Please use a HTML email client',
          :html_body => "<h3>Pages with Errors</h3> <ol>#{html_body_text}</ol>"
)
