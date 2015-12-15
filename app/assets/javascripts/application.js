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
//= require dropzone
//= require moment
//= require bootstrap-daterangepicker
//= require bootstrap-switch
//= require_tree .

$(document).on("submit", "form[data-turboform]", function(e) {
    Turbolinks.visit(this.action+(this.action.indexOf('?') == -1 ? '?' : '&')+$(this).serialize());
    return false;
});

$(document).ready(function(){
    Turbolinks.enableProgressBar();

    $('tr.clickable-row td.clickable').click(function() {
        Turbolinks.visit($(this).parent().data('href'));
    });

    $('#main-content').on('change', 'select#rows-per-page', function(){
        // var rows_val = $(this).find('option:selected').val();
        var active_page = $('#main-content').find('ul.pagination li.active a');

        // var per_page = typeof rows_val != 'undefined' ? rows_val : $(this).find('option:first-child').val();
        var page = typeof active_page.text() != 'undefined' ? active_page.text() : 1;

        properLink(page);
    });

    $('ul.pagination li a').on('click', function(e) {
        e.preventDefault();

        // var rows_pp = $('#main-content').find('select#rows-per-page');
        var page_href = $(this).attr('href');
        var page_start = page_href.indexOf('page=') != -1 ? page_href.indexOf('page=') + 5 : page_href.length;
        var page_end = page_href.substring(page_start).indexOf('&') != -1 ? page_start + page_href.substring(page_start).indexOf('&') : page_href.length;
        var active_page = empty(page_href.substring(page_start, page_end)) ? undefined : page_href.substring(page_start, page_end);

        // var per_page = typeof rows_pp.find('option:selected').val() != 'undefined' ?
        //                    rows_pp.find('option:selected').val() : rows_pp.find('option:first-child').val();
        var page = typeof active_page != 'undefined' ? active_page : 1;

        properLink(page);
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

    $('.select-all').on('click', function() {
        var resource = $(this).data('resource');
        alert('We should first decide what actions will apply to all ' + resource + ' and then return here!');
    });

    $('.select-page').on('click', function() {
        var resource = $(this).data('resource');
        $('table.list-resource td input.'+resource+'-check').prop('checked', true);
        $('table.list-resource td input.'+resource+'-check').trigger('change');
    });

    $('.uncheck-selected').on('click', function() {
        var resource = $(this).data('resource');
        $('table.list-resource td input.'+resource+'-check').prop('checked', false);
        $('table.list-resource td input.'+resource+'-check').trigger('change');
    });

    $('.list-resource').on('change', 'input.resource-check', function() {
        var resource = $(this).data('resource');
        var checked = 0;

        $('table.list-resource td input.resource-check').each(function(index){
            if(this.checked) {
                checked++;
                $('form.list-resource input.resource-check[value="'+this.value+'"]')
                    .prop('checked', true);
            } else {
                $('form.list-resource input.resource-check[value="'+this.value+'"]')
                    .prop('checked', false);
            }
        });

        if(checked > 0) {
            $('.select-action').hide();
            $('.resource-action').show();
        } else {
            $('.resource-action').hide();
            $('.select-action').show();
        }
    });
});
