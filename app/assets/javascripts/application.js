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
        var rows_per_page = $(this).find('option:selected').val();
        var active_page = $('#main-content').find('ul.pagination li.active a');

        var protocol = window.location.protocol;
        var host = window.location.host;
        var path = window.location.pathname;
        var params = window.location.search;

        if(params.indexOf('limit=') == -1) {
            params += empty(params) ? '?limit=' + rows_per_page : '&limit=' + rows_per_page;
        }

        if(params.indexOf('page=') == -1) {
            params += '&page=' + active_page.text();
        }

        // active_page.parent().removeClass('active');
        // active_page.attr('remote', true).attr('href', protocol + '//' + host + path + params);
        // active_page.click();

        Turbolinks.visit(protocol + '//' + host + path + params);
    });
});
