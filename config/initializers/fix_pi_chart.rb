module PiCharts
  class Base
    def html(args = {})
      id     = SecureRandom.uuid
      postfix= args[:name]  || ""
      js_funs = args[:js_funs] || nil
      width  = args[:width]  || "50"
      config = args[:config] || @config.json
      type   = @config.type
      if js_funs
        js_funs.each do |name, val|
          config = config.gsub(/\"__#{name}__\"/, val)
        end
      end


      "<div id=\"canvas-holder\" style=\"width:#{width}%\">
        <canvas id=\"#{id}\" />
      </div>
      <script>
        var config#{postfix} = #{config}
        jQuery(\"document\").ready( function() {
          var ctx = document.getElementById(\"#{id}\").getContext(\"2d\");
          new Chart(ctx, config#{postfix});
        });
      </script>" 
    end 
  end
end