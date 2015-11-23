$(document).ready(function() {
    $('#contact-group-attributes').tagsinput({
        tagClass: 'tag label label-primary',
        confirmKeys: [13, 32, 44],
        maxTags: 20,
        trimValue: true,
        itemValue: '_id',
        itemText: 'lbl',
        typeahead: {
            source: function() {
                return $.get('/typeahead_contact_groups.json');
            }
        },
        freeInput: true
    });

    $('form#contacts-additional').on('mouseup', '.checkbox-js', function() {
        var metadata_column = $(this).attr('rel');
        $('#contacts-table th.'+metadata_column+', #contacts-table td.'+metadata_column).toggleClass('hidden');
    });

    $('#select-all-contacts').on('click', function() {
        alert('We should first decide what actions will apply to all contacts and then return here!');
    });

    $('#select-page-contacts').on('click', function() {
        $('.contact-check').prop('checked', true);
        $('.contact-check').trigger('change');
    });

    $('#uncheck-selected-contacts').on('click', function() {
        $('.contact-check').prop('checked', false);
        $('.contact-check').trigger('change');
    });

    $('#contacts-table').on('change', '.contact-check', function() {
        var contact_checkboxes = document.getElementsByClassName('contact-check');
        var all = contact_checkboxes.length;
        var checked = 0;

        for(i = 0; i < contact_checkboxes.length; i++) {
            if(contact_checkboxes[i].checked) {
                checked++;
            }
        }

        if(checked > 0) {
            $('.select-action').hide();
            $('.resource-action').show();
        } else {
            $('.resource-action').hide();
            $('.select-action').show();
        }
    });

    $('#delete-selected-contacts').on('click', function() {
        var data = $('.contact-check:checked').serialize();

        $.ajax({
            url: '/contacts/bulk_delete',
            cache: false,
            async: false,
            method: 'POST',
            dataType: 'json',
            data: data,
            success: function(result) {
                if(result.deleted > 0) {
                    location.reload();
                } else {
                    console.log('Success: ' + result);
                }
            },
            error: function(result) {
                console.log('Error: ' + result);
            }
        });
    });

    $('form.new_contact, form.edit_contact').on('submit', function(e) {
        var errors = [];

        var prefix = $('#contact_prefix').val().trim();
        var mobile = $('#contact_mobile').val().trim();

        if(empty(prefix)) {
            errors.push(I18n.t('contact_form.prefix_required'));
        } else {
            if(!validMaxLength(prefix, 4)) {
                errors.push(I18n.t('contact_form.prefix_max_length'));
            }

            if(!validNumber(prefix)) {
                errors.push(I18n.t('contact_form.prefix_numeric'));
            }
        }

        if(empty(mobile)) {
            errors.push(I18n.t('contact_form.mobile_required'));
        } else {
            if(!validMinLength(mobile, 6)) {
                errors.push(I18n.t('contact_form.mobile_min_length'));
            } else if(!validMaxLength(mobile, 16)) {
                errors.push(I18n.t('contact_form.mobile_max_length'));
            }

            if(!validNumber(mobile)) {
                errors.push(I18n.t('contact_form.mobile_numeric'));
            }
        }

        return submitForm($(this), errors);
    });

    if(typeof $('form.edit_contact').attr('id') != 'undefined') {
        $.ajax({
            url: '/contacts/'+$('#contact-id').val()+'/groups.json',
            method: 'GET',
            dataType: 'json',
            success: function(result) {
                for(i = 0; i < result.length; i++) {
                    $('#contact-group-attributes').tagsinput('add', { '_id': result[i]['_id'], 'lbl': result[i]['lbl'] });
                    $('#contact-group-attributes').tagsinput('add', { '_id': result[i]['_id'], 'lbl': result[i]['lbl'] });
                }
            },
            error: function(result) {
                console.log('Errorrr... ' + result);
            }
        });
    }
});