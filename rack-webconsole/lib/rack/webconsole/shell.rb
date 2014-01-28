require 'ripl'

class Rack::Webconsole
  module Shell
    def self.eval_query(query, user)
      $sandbox ||= {}
      $sandbox[user] ||= Sandbox.new
      $shell ||= {}
      $shell[user] ||= Ripl::Shell.create(Ripl.config)
      $shell[user].name = user

      # Initialize ripl plugins
      @before_loop_called ||= $shell[user].before_loop

      $shell[user].input = query
      $shell[user].loop_once
      {}.tap do |hash|
        hash[:result] = $shell[user].return_result
        hash[:multi_line] = $shell[user].multi_line?
        hash[:previous_multi_line] = $shell[user].previous_multi_line?
        hash[:prompt] = $shell[user].previous_multi_line? ?
          Ripl.config[:multi_line_prompt] : Ripl.config[:prompt]
      end
    end

    # TODO: move to plugin
    def multi_line?
      @buffer.is_a?(Array)
    end

    def previous_multi_line?
      @old_buffer.is_a?(Array)
    end

    def get_input
      @old_buffer = @buffer
      history << @input
      @input
    end

    def loop_eval(query)
      # Force conversion to symbols due to issues with lovely 1.8.7
      boilerplate = local_variables.map(&:to_sym) + [:ls, :result]

      $sandbox[@name].instance_eval """
        result = (#{query})
        ls = (local_variables.map(&:to_sym) - [#{boilerplate.map(&:inspect).join(', ')}])
        @locals ||= {}
        @locals.update(ls.inject({}) do |hash, value|
          hash.update({value => eval(value.to_s)})
        end)
        result
      """
    end

    def print_eval_error(err)
      @result = "Error: " + err.message
    end

    def return_result
      @error_raised ? result : result.inspect
    end

    def print_result(result) end
  end
end

# Disable readline's #get_input
Ripl.config[:readline] = false
Ripl.config[:multi_line_prompt] = '|| '
Ripl.config[:prompt] = '>> '
Ripl.config[:irbrc] = false
# Let ripl users detect web shells
Ripl.config[:web] = true

Ripl::Shell.include Rack::Webconsole::Shell
# must come after Webconsole plugin
require 'ripl/multi_line'

at_exit { $shell.values.each{ |s| s.after_loop } if $shell && !$shell.empty? }
