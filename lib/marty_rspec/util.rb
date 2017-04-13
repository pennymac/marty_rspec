module MartyRSpec
  module Util
    MAX_WAIT_TIME = 5.0

    # navigation helpers
    def ensure_on(path)
      visit(path) unless current_path == path
    end

    def log_in(username, password)
      wait_for_ready(10)

      if first("a[data-qtip='Current user']")
        log_out
        wait_for_ajax
      end

      find(:xpath, "//span", text: 'Sign in', match: :first, wait: 5).click
      fill_in("login", :with => username)
      fill_in("password", :with => password)
      press("OK")
      wait_for_ajax
    end

    def log_out
      press("Current user")
      press("Sign out")
    end

    def press button_name, args = {}
      index_of = args[:index_of] || 0
      strict = args[:strict] || false
      wait_for_element do
        begin
          cmp = first("a[data-qtip='#{button_name}']")
          cmp ||= first(:xpath, ".//a", text: "#{button_name}") unless strict
          cmp ||= find(:btn, button_name, match: :first)
          cmp.click
          true
        rescue
          find_by_id(ext_button_id(button_name, index_of), visible: :all).click
          true
        end
      end
    end

    def click_checkbox field_label
      find_by_id(ext_checkbox_id(field_label)).click
    end

    def popup message = ''
      wait_for_ready
      yield if block_given?
      close_window
    end

    def close_window
      find(:xpath, '//img[contains(@class, "x-tool-close")]', wait: 5).click
    end

    def zoom_out
      el = find(:body, match: :first)
      el.native.send_keys([:control, '0'])
      el.native.send_keys([:control, '-'])
      el.native.send_keys([:control, '-'])
      el.native.send_keys([:control, '-'])
    end

    #####
    def wait_for_ready wait_time = nil
      if wait_time
        find(:status, 'Ready', wait: wait_time)
      else
        find(:status, 'Ready')
      end
    end

    def wait_for_ajax
      wait_for_ready(10)
      wait_for_element { !ajax_loading? }
      wait_for_ready
    end

    def ajax_loading?
      page.execute_script <<-JS
      return Netzke.ajaxIsLoading() || Ext.Ajax.isLoading();
    JS
    end

    def wait_for_element(seconds_to_wait = 2.0, sleeptime = 0.1)
      res = nil
      start_time = current_time = Time.now
      while !res && current_time - start_time < seconds_to_wait
        begin
          res = yield
        rescue
        ensure
          sleep sleeptime
          current_time = Time.now
        end
      end
      res
    end

    #####
    # note that netzke_find doesn't actually find the component (as in Capybara)
    # instead, it prepares the javascript to be run on the component object
    def netzke_find(name, c_type = 'gridpanel')
      case c_type
      when 'combobox'
        MartyRSpec::Components::NetzkeCombobox.new(name)
      else
        MartyRSpec::Components::NetzkeGrid.new(name, c_type)
      end
    end

    def run_js js_str, seconds_to_wait = MAX_WAIT_TIME, sleeptime = 0.1
      result = wait_for_element(seconds_to_wait, sleeptime) do
        page.document.synchronize { @res = page.execute_script(js_str) }
        @res
      end
      result
    end

    # Component helpers
    def show_submenu text
      run_js <<-JS
      Ext.ComponentQuery.query('menuitem[text="#{text}"] menu')[0].show()
    JS
    end

    def ext_checkbox_id field_label
      c_str = ext_arg('checkbox', fieldLabel: "\"#{field_label}\"")
      run_js <<-JS
      return #{ext_find(c_str)}.id;
    JS
    end

    def ext_button_id title, scope = nil, index_of = 0
      c_str = ext_arg('button{isVisible(true)}', text: "\"#{title}\"")
      run_js <<-JS
      return #{ext_find(c_str, scope, index_of)}.id;
    JS
    end

    def set_field_value value, field_type='textfield', name=''
      args1 = name.empty? ? "" : "[fieldLabel='#{name}']"
      args2 = name.empty? ? "" : "[name='#{name}']"
      run_js <<-JS
      var field = Ext.ComponentQuery.query("#{field_type}#{args1}")[0];
      field = field || Ext.ComponentQuery.query("#{field_type}#{args2}")[0];
      field.setValue("#{value}");
      return true;
    JS
    end

    def get_total_pages
      # will get deprecated by Netzke 1.0
      result = find(:xpath, ".//div[contains(@id, 'tbtext-')]",
                    text: /^of (\d+)$/, match: :first).text
      result.split(' ')[1].to_i
    end

    private
    def simple_escape text
      text.gsub(/(\r\n|\n)/, "\\n")
        .gsub(/\t/, "\\t")
        .gsub(/"/, '\"')
    end

    def paste text, textarea
      # bit hacky: textarea doesn't like receiving tabs and newlines via fill_in
      escaped = simple_escape(text)

      find(:xpath, ".//textarea[@name='#{textarea}']")
      run_js <<-JS
      #{ext_var(ext_find(ext_arg('textarea', name: textarea)), 'area')}
      area.setValue("#{escaped}");
      return true;
    JS
    end

    def btn_disabled? text
      res = wait_for_element do
        find_by_id(ext_button_id(text))
      end
      !res[:class].match(/disabled/).nil?
    end

    # Field edit/Key in Helpers
    def type_in(type_s, el, args = {})
      extra_keys = args[:extra_keys] || [:enter]
      el = find_by_id("#{el}") if el.is_a? String
      el.native.clear()
      type_s.each_char do |key|
        el.native.send_keys(key)
      end
      el.send_keys(extra_keys)
    end

    def press_key_in(key, el)
      kd = key.downcase
      use_key = ['enter', 'return'].include?(kd) ? kd.to_sym : key
      el = find_by_id("#{el}") if el.is_a? String
      el.native.send_keys(use_key)
    end

    # Netzke component lookups, arguments for helper methods
    # (i.e. component) require JS scripts instead of objects
    def ext_arg(component, c_args = {})
      res = component
      c_args.each do |k, v|
        res += "[#{k.to_s}=#{v.to_s}]"
      end
      res
    end

    def ext_find(ext_arg_str, scope = nil, index = 0)
      scope_str = scope.nil? ? '' : ", #{scope}"
      <<-JS
      Ext.ComponentQuery.query('#{ext_arg_str}'#{scope_str})[#{index}]
    JS
    end

    def ext_var(ext_find_str, var_name='ext_c')
      <<-JS
      var #{var_name} = #{ext_find_str};
    JS
    end

    def ext_netzkecombo field
      <<-JS
      #{ext_find(ext_arg('netzkeremotecombo', name: field))}
    JS
    end

    def ext_combo combo_label, c_name='combo'
      <<-JS
      #{ext_var(ext_find(ext_arg('combobox', fieldLabel: combo_label)), c_name)}
      #{c_name} = #{c_name} ||
                  #{ext_find(ext_arg('combobox', name: combo_label))};
    JS
    end

    def ext_celleditor(grid_name='grid')
      <<-JS
      #{grid_name}.getPlugin('celleditor')
    JS
    end

    def ext_row(row, grid_name='grid')
      <<-JS
      #{grid_name}.getStore().getAt(#{row})
    JS
    end

    def ext_col(col, grid_name='grid')
      <<-JS
      #{ext_find(ext_arg('gridcolumn', name: "\"#{col}\""), grid_name)}
    JS
    end

    def ext_cell_val(row, col, grid, var_str = 'value')
      <<-JS
      #{ext_var(grid, 'grid')}
      #{ext_var(ext_col(col, 'grid'), 'col')}
      #{ext_var(ext_row(row, 'grid'), 'row')}
      var #{var_str} = col.assoc ?
        row.get('association_values')['#{col}'] :
        row.get('#{col}');
    JS
    end

    ##############
    # DEPRECATED #
    ##############

    # Combobox Helpers, now separate component, like grid
    def select_combobox(values, combo_label)
      warn "[DEPRECATED] use netzke_find('#{combo_label}', 'combobox').select_values(values)"
      run_js <<-JS
      var values = #{values.split(/,\s*/)};
      #{ext_combo(combo_label)}

      var arr = new Array();
      for(var i=0; i < values.length; i++) {
        arr[i] = combo.findRecordByDisplay(values[i]);
      }
      combo.select(arr);
      if (combo.isExpanded) {
        combo.onTriggerClick();
        return true;
      };
    JS
    end

    def combobox_values(combo_label)
      warn "[DEPRECATED] use netzke_find('#{combo_label}', 'combobox').get_values"
      run_js <<-JS
      #{ext_combo(combo_label)}
      var values = [];
      combo.getStore().each(
        function(r) { values.push(r.data.text || r.data.field1); });
      return values;
    JS
    end

    def click_combobox combo_label
      warn "[DEPRECATED] use netzke_find('#{combo_label}', 'combobox').click"
      run_js <<-JS
      #{ext_combo(combo_label)}
      combo.onTriggerClick();
      return true;
    JS
      wait_for_element { !ajax_loading? }
    end

    def custom_selectors
      # automatically loaded now
      warn "[DEPRECATED] automatically loaded"
    end
  end
end
