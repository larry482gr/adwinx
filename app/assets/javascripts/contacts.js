$(document).ready(function(){
    $('tr.clickable-row td:not(:last-child)').click(function() {
        Turbolinks.visit($(this).parent().data('href'));
    });
});