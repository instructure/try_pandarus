require 'sinatra'
require 'rack/webconsole'
require 'rack/session/cookie'
require 'pandarus'

Rack::Webconsole.inject_jquery = true

use Rack::Session::Cookie, :secret => 'w.e.b-c.o.n.s.o.l.e'
use Rack::Webconsole

configure do
  disable :protection
end

# after do
#   response.body << <<-HTML
#     <script>
#     $(document).ready(function() {
#       $("#rack-webconsole").slideToggle('fast', function() {
#         if ($(this).is(':visible')) {
#           $("#rack-webconsole form input").focus();
#           $("#rack-webconsole .results_wrapper").scrollTop(
#             $("#rack-webconsole .results").height()
#           );
#         } else {
#           $("#rack-webconsole form input").blur();
#         }
#       });
#     });
#     </script>
#   HTML
# end

def intro
end

def clear
  "~<script>$('.results').html('')</script>"
end

def help
  "~<h5>Pandarus says: 'How may I help you?'</h5>" +
  "<ul>" +
  "<li><h5>Type 'client_help' for help in setting up your Pandarus Client.</h5></li>" +
  "</ul>"
end

def client_help
    "~<h5>To set up your Pandarus Client, paste this into your input box:</h5>" +
    "<span>'client = Pandarus::V1_api.new(prefix: '', token: '')<span>" +
    "<h5>Prefix should look like: 'https://canvas.instructure.com/api'</h5>"+
    "<h5>Token should be your own Canvas API Token <a href=''><span class='glyphicon glyphicon-info-sign'></span><a/> : '76uytit87tyuiy98iuy897yiouy98oiuyy987'"
end
def search(*words)
  "~" + Pandarus::V1_api.instance_methods.select do |method|
    words.all? do |word|
      method =~ /.*#{word}.*/
    end
  end.map do |method_name|
    method = Pandarus::V1_api.instance_method(method_name.to_sym)
    "<span style='color:orange'>#{method_name}</span><br>" +
    method.parameters.map do |req_opt, param_name|
      if req_opt == :req
        "&nbsp;&nbsp;<span style='text-decoration:underline'>#{param_name}</span> (#{req_opt})"
      else
        "&nbsp;&nbsp;#{param_name} (#{req_opt})"
      end
    end.join("<br>")
  end.join("<br><br>")
end

def exercise(number)
  case number
  when 1
    "~<h4 class='text-primary'><span style='color:red'>&hearts;</span>&nbsp;Exercise 1: Create a Pandarus client</h4>" +
    "<h5 class='text-muted'>Create a 'client' by typing the following (include your own API token):</h5>" +
    "<span style='color:#feef99'>client = Pandarus::V1_api.new(prefix: 'https://pandamonium.instructure.com/api', token: '')</span>"
  when 2
    "~<h4 class='text-primary'><span style='color:red'>&hearts;</span> Exercise 2: Search for Pandarus methods</h4>" +
    "<h5 class='text-muted'><span class='glyphicon glyphicon-search'></span></i>&nbspTry searching for methods that get a course:</h5>" +
    "<span style='color:#feef99'>search 'get', 'course'</span>"
  when 3
    "~<h4 class='text-primary'><span style='color:red'>&hearts;</span> Exercise 3: Find courses with SIS ID 'PANDA-101'</h4>" +
    "<span style='color:#feef99'>client.get_single_course_courses('sis_course_id:PANDA-101', '').id</span><br>" +
    "also note that this does the same thing:<br>" +
    "<span style='color:orange'>client.get_single_course_courses(17, '').id</span>"
  when 4
    "~<span style='color:red'>&hearts;</span> Exercise 4: List users in this course<br>" +
    "(Tip: try searching for methods that 'list' 'users' in a 'course')<br><br>" +
    "Get users in PANDA-101:<br>" +
    "<span style='color:#feef99'>client.list_users_in_course_courses(17, '')</span>"
  when 5
    "~That's it! Thanks for trying the exercises out.<br>" +
    "Now you can try other methods if you'd like to..."
  else
    "I don't have any exercise number #{number} for you."
  end
end

get '/' do
  <<-HTML
  <html>
  <head>
    <title>Try Pandarus</title>
  </head>
  <body style='background-color: #000;'>
  </body>
  </html>
  HTML
end

get '/panda.gif' do
  send_file 'panda.gif'
end
