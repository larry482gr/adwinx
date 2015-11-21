// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.turbolinks
//= require bootstrap-sprockets
//= require bootstrap-tagsinput.min
//= require bootstrap3-typeahead.min
//= require turbolinks
//= require i18n
//= require i18n/translations
//= require_tree .

$(document).ready(function(){
    Turbolinks.enableProgressBar();

    $('tr.clickable-row td.clickable').click(function() {
        Turbolinks.visit($(this).parent().data('href'));
    });

    $('#main-content').on('change', 'select#rows-per-page', function(){
        var rows_val = $(this).find('option:selected').val();
        var active_page = $('#main-content').find('ul.pagination li.active a');

        var per_page = typeof rows_val != 'undefined' ? rows_val : $(this).find('option:first-child').val();
        var page = typeof active_page.text() != 'undefined' ? active_page.text() : 1;

        properLink(page, per_page);
    });

    $('ul.pagination li a').on('click', function(e) {
        e.preventDefault();

        var rows_pp = $('#main-content').find('select#rows-per-page');
        var page_href = $(this).attr('href');
        var page_start = page_href.indexOf('page=') + 5;
        var page_end = page_href.substring(page_start).indexOf('&') != -1 ? page_href.substring(page_start).indexOf('&') : page_href.length;
        var active_page = page_href.substring(page_start, page_end);

        var per_page = typeof rows_pp.find('option:selected').val() != 'undefined' ?
                            rows_pp.find('option:selected').val() : rows_pp.find('option:first-child').val();
        var page = typeof active_page != 'undefined' ? active_page : 1;

        properLink(page, per_page);
    });

    var window_params = window.location.search;
    if(!empty(window_params)) {
        var params_array = window_params.substring(1).split('&');
        var table_id = $('form.additional-fields').attr('id').replace('additional', 'table');

        $.each(params_array, function(key, value) {
            var field_array = value.split('=');
            var checkbox_field = $('form.additional-fields div.checkbox-js[rel="'+field_array[0]+'"] input[type="checkbox"]');

            if(typeof checkbox_field != 'undefined') {
                if(checkbox_field.is(':checked') && field_array[1] == 0) {
                    checkbox_field.prop('checked', false);
                    $('table#'+table_id+' th.' + field_array[0]).addClass('hidden');
                    $('table#'+table_id+' td.' + field_array[0]).addClass('hidden');
                } else if(!checkbox_field.is(':checked') && field_array[1] == 1) {
                    checkbox_field.prop('checked', true);
                    $('table#'+table_id+' th.' + field_array[0]).removeClass('hidden');
                    $('table#'+table_id+' td.' + field_array[0]).removeClass('hidden');
                }
            }
        });
    }

    function properLink(page, per_page) {
        var protocol = window.location.protocol;
        var host = window.location.host;
        var path = window.location.pathname;
        var params = '';

        params += '?limit=' + per_page;
        params += '&page=' + page;

        params = params + additional_fields();

        Turbolinks.visit(protocol + '//' + host + path + params);
    }

    function additional_fields() {
        var additional_params = '';
        if(typeof $('form.additional-fields') != 'undefined') {
            var check_val = 0;

            $('form.additional-fields div.checkbox-js').each(function(index) {
                check_val = $(this).find('input[type="checkbox"]').is(':checked') ? 1 : 0;
                additional_params += '&' + $(this).attr('rel') + '=' + check_val;
            });
        }

        return additional_params;
    }
});
