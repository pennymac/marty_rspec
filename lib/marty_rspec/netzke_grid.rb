require 'capybara/dsl'

module MartyRspec
  module NetzkeGrid
    def self.netzke_find(name, grid_type = 'gridpanel')
      NetzkeGridNode.new(name, grid_type)
    end

    class NetzkeGridNode
      include Util
      include Capybara::DSL

      attr_reader :name, :grid

      def initialize(name, grid_type)
        @name = name
        if /^\d+$/.match(name)
          @grid = ext_find(grid_type, nil, name)
        else
          @grid = ext_find(ext_arg(grid_type, name: name))
        end
      end

      def id
        res = run_js <<-JS
          var c = #{grid};
          return c.view.id;
        JS
        res
      end

      def row_count
        res = run_js <<-JS
          return #{grid}.getStore().getTotalCount();
        JS
        res.to_i
      end

      def row_total
        res = run_js <<-JS
          return #{grid}.getStore().getTotalCount();
        JS
        res.to_i
      end

      def row_modified_count
        res = run_js <<-JS
          return #{grid}.getStore().getUpdatedRecords().length;
        JS
        res.to_i
      end

      def data_desc row
        res = run_js <<-JS
          var r = #{grid}.getStore().getAt(#{row.to_i-1});
          return r.data.desc
        JS
        res.gsub(/<.*?>/, '')
      end

      def click_col col
        run_js <<-JS
          #{ext_find(ext_arg('gridcolumn', text: col), grid)}.click();
        JS
      end

      def col_values(col, cnt, init=0)
        #does not validate the # of rows
        run_js <<-JS
          var result = [];
          for (var i = #{init}; i < #{init.to_i + cnt.to_i}; i++) {
            #{ext_cell_val('i', col, grid)}
            if(value instanceof Date){
              result.push(value.toISOString().substring(0,value.toISOString().indexOf('T')));
            } else {
              result.push(value);
            };
          };
          return result;
        JS
      end

      def cell_value(row, col)
        run_js <<-JS
          #{ext_cell_val(row.to_i - 1, col, grid)}
          return value;
        JS
      end

      def select_row(row)
        resid = run_js(<<-JS, 10.0)
          #{ext_var(grid, 'grid')}
          grid.getSelectionModel().select(#{row.to_i-1});
          return grid.getView().getNode(#{row.to_i-1}).id;
        JS
        el = find_by_id(resid)
        return el
      end

      def set_row_vals row, fields
        js_set_fields = fields.each_pair.map do |k,v|
          "r.set('#{k}', '#{v}');"
        end.join

        run_js <<-JS
          #{ext_var(ext_row(row.to_i - 1, grid), 'r')}
          #{js_set_fields}
        JS
      end

      def validate_row_values row, fields
        js_get_fields = fields.each_key.map do |k|
          <<-JS
            var col = Ext.ComponentQuery.query('gridcolumn[name=\"#{k}\"]', grid)[0];
            var value = col.assoc ? r.get('meta').associationValues['#{k}'] :
                                    r.get('#{k}');
            if (value instanceof Date) {
              obj['#{k}'] = value.toISOString().substring(0,
                value.toISOString().indexOf('T'));
            } else {
              obj['#{k}'] = value;
            };
          JS
        end.join

        res = run_js <<-JS
          #{ext_var(grid, 'grid')}
          #{ext_var(ext_row(row.to_i - 1, 'grid'), 'r')}
          var obj = {};
          #{js_get_fields}
          return obj;
        JS
        wait_for_element { expect(res).to eq fields.stringify_keys }
      end

      def sorted_by? col, direction = 'asc'
        run_js <<-JS
          #{ext_var(grid, 'grid')}
          #{ext_var(ext_col(col, 'grid'), 'col')}
          var colValues = [];

          grid.getStore().each(function(r){
            var val = col.assoc ? r.get('meta').associationValues['#{col}'] :
                                  r.get('#{col}');
            if (val) colValues.#{direction == 'asc' ? 'push' : 'unshift'}(val);
          });

          return colValues.toString() === Ext.Array.sort(colValues).toString();
        JS
      end

      def grid_combobox_values(row, field)
        run_js <<-JS
          #{start_edit_grid_combobox(row, field, grid)}
        JS

        # hacky: delay for combobox to render, assumes combobox is not empty
        run_js <<-JS
          #{ext_var(grid, 'grid')}
          #{ext_var(ext_netzkecombo(field), 'combo')}
          var r = [];
          #{ext_var(ext_celleditor, 'editor')}
          var store = combo.getStore();

          // force a retry if the store is still loading
          if (store.loading == true) { throw "store not loaded yet"; }

          for(var i = 0; i < store.getCount(); i++) {
            r.push(store.getAt(i).get('text'));
          };

          editor.completeEdit();
          return r;
        JS
      end

      def get_grid_combobox_val(index, row, field)
        run_js <<-JS
          #{start_edit_grid_combobox(row, field, grid)}
        JS

        run_js <<-JS
          #{ext_var(grid, 'grid')}
          #{ext_var(ext_netzkecombo(field), 'combo')}
          #{ext_var(ext_celleditor, 'editor')}
          var val = combo.getStore().getAt(#{index}).get('text');
          editor.completeEdit();
          return val;
        JS
      end

      def start_edit_grid_combobox(row, field)
        <<-JS
          #{ext_var(grid, 'grid')}
          #{ext_var(ext_netzkecombo(field), 'combo')}
          #{ext_var(ext_celleditor, 'editor')}

          editor.startEditByPosition({ row:#{row.to_i-1},
            column:grid.headerCt.items.findIndex('name', '#{field}') });

          var now = new Date().getTime();
          while(new Date().getTime() < now + 500) { }

          combo.onTriggerClick();
        JS
      end

      def id_of_edit_field(row, field)
        res = run_js <<-JS
          #{ext_var(grid, 'grid')}
          #{ext_var(ext_celleditor, 'editor')}

          editor.startEditByPosition({ row:#{row.to_i-1},
            column:grid.headerCt.items.findIndex('name', '#{field}') });
          return editor.activeEditor.field.inputId;
        JS
        res
      end

      def end_edit(row, field)
        run_js <<-JS
          #{ext_var(grid, 'grid')}
          #{ext_var(ext_celleditor, 'editor')}
          editor.completeEdit();
          return true;
        JS
      end
    end
  end
end
