$(document).ready(function() {
    var groups = [];

    if(typeof $('#contact-group-attributes').val() != 'undefined') {
        groups = $.get('/typeahead_contact_groups.json');
    }

    $('#contact-group-attributes').tagsinput({
        tagClass: 'tag label label-primary',
        confirmKeys: [13, 32, 44],
        maxTags: 20,
        trimValue: true,
        itemValue: '_id',
        itemText: 'lbl',
        typeahead: {
            source: groups
        },
        trimValue: true
    });

    $('form#contacts-filters div.bootstrap-tagsinput').addClass('form-group');
    $('form#contacts-filters div.bootstrap-tagsinput input').css('width', 'auto !important')
        .css('height', '32px').css('line-height', '1.42857').css('padding', '6px 12px !important');



    $('form#contacts-additional').on('mouseup', '.checkbox-js', function() {
        var metadata_column = $(this).attr('rel');
        $('#contacts-table th.'+metadata_column+', #contacts-table td.'+metadata_column).toggleClass('hidden');
    });

    $('button#import-contacts').on('click', function() {
        $('div#contacts-drop-area').slideToggle();
    });

    /*
     *  TODO Refactor as bulk remove from group (form, appropriate method etc.)
     *  --> Follow rails security patterns for CSRF attacks.
     */
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