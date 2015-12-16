$(document).ready(function() {
    $('form.new_template, form.edit_template').on('submit', function(e) {
        var errors = [];

        var label = $('#template_label').val().trim();
        var msg_body = $('#template_msg_body').val().trim();

        if(empty(label)) {
            errors.push(I18n.t('template_form.label_required'));
        } else if(!validMaxLength(label, 20)) {
            errors.push(I18n.t('template_form.label_length'));
        }

        //if(!validMaxLength(msg_body, 120)) {
        //    errors.push(I18n.t('contact_group_form.description_length'));
        //}

        return submitForm($(this), errors);
    });

    $('#remove-selected-templates').on('click', function() {
        var total_selected = 0;
        $('table.list-resource td input.resource-check').each(function(index){
            if(this.checked) {
                total_selected++;
            }
        });

        $(this).data('confirm', $(this).data('confirm').replace(/[0-9]*\s/, total_selected + ' '));
    });

    $('button.delete-group').on('click', function() {
        if(!$(this).hasClass('multi')) {
            $('form#delete-templates').attr('action', '/templates/' + $(this).data('templateid'));
            $('ol#delete-templates-modal-list').html('<li>' + $(this).data('templatelabel') + '</li>');
        } else {
            $('form#delete-templates').attr('action', '/templates/bulk_delete');

            var selected_groups = '';
            $('form#delete-templates input.template-check').each(function() {
                if(this.checked) {
                    selected_groups += '<li>' + $(this).attr('rel') + '</li>';
                }
            });

            $('ol#delete-templates-modal-list').html(selected_groups);
        }
    });
});
