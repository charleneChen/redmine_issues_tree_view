/**
 * Created by charlene on 9/8/16.
 */

function initFilters() {
    $('#add_filter_select').change(function() {
        addFilter($(this).val(), '', []);
    });
    $('#filters-table td.field input[type=checkbox]').each(function() {
        toggleFilter($(this).val());
    });
    $('#filters-table').on('click', 'td.field input[type=checkbox]', function() {
        toggleFilter($(this).val());
    });
    $('#filters-table').on('click', '.toggle-multiselect', function() {
        toggleMultiSelect($(this).siblings('select'));
    });
    $('#filters-table').on('keypress', 'input[type=text]', function(e) {
        if (e.keyCode == 13) $(this).closest('form').submit();
    });
}

function addFilter(field, operator, values) {
    var fieldId = field.replace('.', '_');
    var tr = $('#tr_'+fieldId);
    if (tr.length > 0) {
        tr.show();
    } else {
        buildFilterRow(field, operator, values);
    }
    $('#cb_'+fieldId).prop('checked', true);
    toggleFilter(field);
    $('#add_filter_select').val('').find('option').each(function() {
        if ($(this).attr('value') == field) {
            $(this).attr('disabled', true);
        }
    });
}