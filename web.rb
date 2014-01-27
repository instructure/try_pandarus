require 'sinatra'
require 'rack/webconsole'
require 'pandarus'

Rack::Webconsole.inject_jquery = true

use Rack::Webconsole

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

def get_single_course_courses
  "get_single_course_courses(id,include,opts={})"
end

def search(*words)
  "~" + Pandarus::V1_api.instance_methods.select do |method|
    words.all? do |word|
      method =~ /.*#{word}.*/
    end
  end.map do |method_name|
    method = Pandarus::V1_api.instance_method(method_name.to_sym)
    method_name.to_s + "<br>" +
    method.parameters.map do |req_opt, param_name|
      "&nbsp;&nbsp;#{param_name} (#{req_opt})"
    end.join("<br>")
  end.join("<br><br>")
end

def exercise(number)
  case number
  when 1
    "~Exercise 1: Create a Pandarus client<br><br>" +
    "Create a 'client' by typing the following (include your own token):<br>" +
    "<span style='color:red'>client = Pandarus::V1_api.new(prefix: 'https://pandamonium.instructure.com/api', token: '')</span>"
  when 2
    "~Exercise 2: Search for Pandarus methods<br><br>" +
    "Try searching for methods that list users in a course:<br>" +
    "<span style='color:red'>search 'users', 'list'</span>"
  when 3
    "~Exercise 3: Find courses with SIS ID 'PANDA-101'<br><br>" +
    ""
  when 4
    "~Exercise 4: List users in this course<br><br>" +
    "Get users in PANDA-101:<br>" +
    "<span style='color:red'>client.list_users_in_course_courses(17)</span>"
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
  <body>
    Try Pandarus
  </body>
  </html>
  HTML
end
