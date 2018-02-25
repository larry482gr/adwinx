$(document).ready(function() {
    $('form.new_contact_group, form.edit_contact_group').on('submit', function(e) {
        var errors = [];

        var label = $('#contact_group_label').val().trim();
        var description = $('#contact_group_description').val().trim();

        if(empty(label)) {
            errors.push(I18n.t('contact_group_form.label_required'));
        } else if(!validMaxLength(label, 20)) {
            errors.push(I18n.t('contact_group_form.label_length'));
        }

        if(!validMaxLength(description, 120)) {
            errors.push(I18n.t('contact_group_form.description_length'));
        }

        return submitForm($(this), errors);
    });

    $('#remove-selected-contacts').on('click', function() {
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
            $('form#delete-contact-groups').attr('action', '/contact_groups/' + $(this).data('groupid'));
            $('ol#delete-groups-modal-list').html('<li>' + $(this).data('grouplabel') + '</li>');
        } else {
            $('form#delete-contact-groups').attr('action', '/contact_groups/bulk_delete');

            var selected_groups = '';
            $('form#delete-contact-groups input.contact-group-check').each(function() {
                if(this.checked) {
                    selected_groups += '<li>' + $(this).attr('rel') + '</li>';
                }
            });

            $('ol#delete-groups-modal-list').html(selected_groups);
        }
    });

    $('#delete-groups-modal').on('shown.bs.modal', function () {
        $('#contact-group-contacts-fate-0').prop('checked', true);
    })
});