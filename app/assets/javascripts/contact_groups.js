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
});