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
    "~<span style='color:red'>&hearts;</span> Exercise 1: Create a Pandarus client<br><br>" +
    "Create a 'client' by typing the following (include your own API token):<br>" +
    "<span style='color:#feef99'>client = Pandarus::V1_api.new(prefix: 'https://pandamonium.instructure.com/api', token: '')</span>"
  when 2
    "~<span style='color:red'>&hearts;</span> Exercise 2: Search for Pandarus methods<br><br>" +
    "Try searching for methods that get a course:<br>" +
    "<span style='color:#feef99'>search 'get', 'course'</span>"
  when 3
    "~<span style='color:red'>&hearts;</span> Exercise 3: Find courses with SIS ID 'PANDA-101'<br><br>" +
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
  <body>
    Try Pandarus
  </body>
  </html>
  HTML
end
