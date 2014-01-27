(function($) {
  
  var webconsole = {
    history:[],
    pointer:0,
    query:$('#webconsole_query')
  }
  
  $('#rack-webconsole form').submit(function(e){
    e.preventDefault();
  });

  $("#rack-webconsole form input").keyup(function(event) {
    function escapeHTML(string) {
      return(string.replace(/&/g,'&amp;').
        replace(/>/g,'&gt;').
        replace(/</g,'&lt;').
        replace(/"/g,'&quot;')
      );
    };

    // enter
    if (event.which == 13) {
      webconsole.history.push(webconsole.query.val());
      webconsole.pointer = webconsole.history.length - 1;
      $.ajax({
        url: '$CONTEXT/webconsole',
        type: 'POST',
        dataType: 'json',
        data: ({query: webconsole.query.val(), token: "$TOKEN"}),
        success: function (data) {
          var query_class = data.previous_multi_line ? 'query_multiline' : 'query';
          var result = "<div class='" + query_class + "'>" +
            escapeHTML(data.prompt + webconsole.query.val()) + "</div>";
          if (!data.multi_line) {
            // console.log('data not multi_line');
            // gData = data;
            if (data.result[1] == "~")
              result += "<div class='result'>" + data.result.substring(2, data.result.length-1) + "</div>";
            else
              result += "<div class='result'>" + escapeHTML("=> " + data.result) + "</div>";
          }
          $("#rack-webconsole .results").append(result);
          $("#rack-webconsole .results_wrapper").scrollTop(
            $("#rack-webconsole .results").height()
          );
          webconsole.query.val('');
        }
      });
    }
    
    // up
    if (event.which == 38) {
      if (webconsole.pointer < 0) {
        webconsole.query.val('');
      } else {
        if (webconsole.pointer == webconsole.history.length) {
          webconsole.pointer = webconsole.history.length - 1;
        }
        webconsole.query.val(webconsole.history[webconsole.pointer]);
        webconsole.pointer--;
      }
    }
    
    // down
    if (event.which == 40) {
      if (webconsole.pointer == webconsole.history.length) {
        webconsole.query.val('');
      } else {
        if (webconsole.pointer < 0) {
          webconsole.pointer = 0;
        }
        webconsole.query.val(webconsole.history[webconsole.pointer]);
        webconsole.pointer++;
      }
    }
    
  });

  $(document).ready(function() {
    $("#rack-webconsole").slideToggle('fast', function() {
      if ($(this).is(':visible')) {
        $("#rack-webconsole form input").focus();
        $("#rack-webconsole .results_wrapper").scrollTop(
          $("#rack-webconsole .results").height()
        );
      } else {
        $("#rack-webconsole form input").blur();
      }
      $("#rack-webconsole .banner").append("Welcome to Try Pandarus!<br><br>");
      $("#rack-webconsole .banner").append("Pandarus Docs: <a href='http://rubydoc.info/gems/pandarus/Pandarus/V1_api'>http://rubydoc.info/gems/pandarus/Pandarus/V1_api</a><br><br>");
      $("#rack-webconsole .banner").append("To try an exercise, type:<br>");
      $("#rack-webconsole .banner").append("  exercise 1<br>");
      $("#rack-webconsole .banner").append("  exercise 2(..4)<br>");

      webconsole.query.val('exercise 1')
    });
  });
})(jQuery);
