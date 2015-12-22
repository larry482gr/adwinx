$(document).ready(function() {
    if(typeof $('button#restricted-hours-add').text() != 'undefined') {
        var sms_restricted_counter = 0;
    }

    var groups = [];

    if(typeof $('select#sms_campaign_sms_recipient_list_attributes_contact_groups').val() != 'undefined') {
        groups = $.get('/typeahead_contact_groups.json');
    }

    $('select#sms_campaign_sms_recipient_list_attributes_contact_groups').tagsinput({
        tagClass: 'tag label label-primary',
        confirmKeys: [13, 32, 44],
        maxTags: 20,
        trimValue: true,
        itemValue: '_id',
        itemText: 'lbl',
        typeahead: {
            source: groups
        }
    });

    $('select#sms_campaign_sms_recipient_list_attributes_contacts').tagsinput({
        tagClass: 'tag label label-primary',
        confirmKeys: [13, 32, 44],
        maxTags: 20,
        trimValue: true,
        // itemValue: '_id',
        // itemText: 'lbl',
    });

    $('form.sms-campaign-form div.bootstrap-tagsinput').addClass('form-control');
    $('form.sms-campaign-form div.bootstrap-tagsinput input').css('width', 'auto');

    if (!sessionStorage.getItem('timezone')) {
        var tz = jstz.determine() || 'UTC';
        sessionStorage.setItem('timezone', tz.name());
    }
    var currTz = sessionStorage.getItem('timezone');

    if(typeof $('select#sms_campaign_timezone').val() != 'undefined') {
        $('select#sms_campaign_timezone option').each(function(idx, elem){
            if(elem.value.indexOf(currTz) !== -1) {
                $(this).prop('selected', true);
                moment.tz.setDefault($(this).val());
            }
        });

        setSmsCampaignDateTimeRange();
    }

    $('select#sms_campaign_timezone').on('change', function() {
        moment.tz.setDefault($(this).val());
        $('.daterangepicker').remove();
        setSmsCampaignDateTimeRange();
    });

    $('input#restricted-hours-check').on('change', function() {
        if(this.checked) {
            $(this).parent().next().find('select').prop('disabled', false);
            $(this).parent().parent().find('span > button').prop('disabled', false);
        } else {
            $(this).parent().next().find('select').prop('disabled', true);
            $(this).parent().parent().find('span > button').prop('disabled', true);
        }
    });

    $('button#restricted-hours-add').on('click', function() {
        var restricted_hours_div = $(this).parent().parent().find('div').first();
        restrictedHoursHelp(restricted_hours_div);

        var new_hours = restricted_hours_div.clone();
        var new_hours_div = new_hours.html();

        new_hours_div = replaceAll(new_hours_div,
                                    'attributes_' + sms_restricted_counter + '_',
                                    'attributes_' + (sms_restricted_counter+1) + '_'
                                  );
        new_hours_div = replaceAll(new_hours_div,
                                    'attributes][' + sms_restricted_counter + ']',
                                    'attributes][' + ++sms_restricted_counter + ']'
                                  );

        new_hours.html(new_hours_div);

        restricted_hours_div.addClass('hidden');
        restricted_hours_div.before(new_hours);

        $('input#restricted-hours-check').click();
    });

    function restrictedHoursHelp(restricted_hours_div) {
        var comma_separator = $('p#restricted-hours-help > span').text().length > 0 ? ', ' : '';
        var help_block = '';

        restricted_hours_div.find('select').each(function() {
            help_block += $(this).val() + ':';
        });

        help_block = help_block.substring(0,5) + ' - ' + help_block.substring(6,11);

        $('p#restricted-hours-help').show().find('span').append(comma_separator + help_block);
    }

    $('input[name="sms_campaign[encoding]"]').val(0);
    $('input#sms_campaign_encoding').on('change', function() {
       if(this.checked) {
           $(this).parent().find('input').val(2);
       } else {
           $(this).parent().find('input').val(0);
       }
    });

    $('input[name="sms_campaign[on_screen]"]').val(1);
    $('input#sms_campaign_on_screen').on('change', function() {
        if(this.checked) {
            $(this).parent().find('input').val(0);
        } else {
            $(this).parent().find('input').val(1);
        }
    });

    function setSmsCampaignDateTimeRange() {
        $('input#sms-campaign-valid-datetime').daterangepicker({
            "timePicker": true,
            "timePicker24Hour": true,
            ranges: {
                'Today': [
                    moment(),
                    moment().hour(23).minutes(59).seconds(59)
                ],
                'Tomorrow': [
                    moment().add(1, 'days'),
                    moment().add(1, 'days').hour(23).minutes(59).seconds(59)
                ],
                'Next 7 Days': [
                    moment(),
                    moment().add(6, 'days').hour(23).minutes(59).seconds(59)
                ],
                'Next 30 Days': [moment(),
                    moment().add(29, 'days').hour(23).minutes(59).seconds(59)
                ],
                'This Month': [
                    moment(),
                    moment().endOf('month').hour(23).minutes(59).seconds(59)
                ],
                'Next Month': [
                    moment().add(1, 'month').startOf('month'),
                    moment().add(1, 'month').endOf('month').hour(23).minutes(59).seconds(59)
                ]
            },
            "locale": {
                "format": "YYYY/MM/DD",
                "separator": " - ",
                "applyLabel": "Apply",
                "cancelLabel": "Cancel",
                "fromLabel": "From",
                "toLabel": "To",
                "customRangeLabel": "Custom",
                "daysOfWeek": [
                    "Su",
                    "Mo",
                    "Tu",
                    "We",
                    "Th",
                    "Fr",
                    "Sa"
                ],
                "monthNames": [
                    "January",
                    "February",
                    "March",
                    "April",
                    "May",
                    "June",
                    "July",
                    "August",
                    "September",
                    "October",
                    "November",
                    "December"
                ],
                "firstDay": 1
            },
            "linkedCalendars": false,
            "autoUpdateInput": false,
            "startDate": moment(),
            "endDate": moment().hour(23).minutes(59).seconds(59)
        });

        $('input#sms-campaign-valid-datetime').on('apply.daterangepicker', function(ev, picker) {
            start   = picker.startDate;
            end     = picker.endDate;

            startUnix   = start.unix();
            endUnix     = end.unix();

            $('p#valid-datetime-help').show()
                .html(start.format('YYYY/MM/DD HH:mm') + ' - ' + end.format('YYYY/MM/DD HH:mm') + ' (local time)<br>' +
                      start.utc().format('YYYY/MM/DD HH:mm') + ' - ' + end.utc().format('YYYY/MM/DD HH:mm') + ' (UTC)');

            $('input#sms_campaign_start_date').val(startUnix);
            $('input#sms_campaign_end_date').val(endUnix);
        });
    }
});
