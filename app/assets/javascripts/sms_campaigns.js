$(document).ready(function() {
    var groups = [];

    if(typeof $('#sms-campaign-contact-groups').val() != 'undefined') {
        groups = $.get('/typeahead_contact_groups.json');
    }

    $('#sms-campaign-contact-groups').tagsinput({
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

    $('#sms-campaign-contacts').tagsinput({
        tagClass: 'tag label label-primary',
        confirmKeys: [13, 32, 44],
        maxTags: 20,
        trimValue: true,
        // itemValue: '_id',
        // itemText: 'lbl',
    });

    if (!sessionStorage.getItem('timezone')) {
        var tz = jstz.determine() || 'UTC';
        sessionStorage.setItem('timezone', tz.name());
    }
    var currTz = sessionStorage.getItem('timezone');

    if(typeof $('select#campaign_time_zone').val() != 'undefined') {
        $('select#campaign_time_zone option').each(function(idx, elem){
            if(elem.value.indexOf(currTz) !== -1) {
                $(this).prop('selected', true);
                moment.tz.setDefault($(this).val());
            }
        });

        setSmsCampaignDateTimeRange();
    }

    $('select#campaign_time_zone').on('change', function() {
        moment.tz.setDefault($(this).val());
        $('.daterangepicker').remove();
        setSmsCampaignDateTimeRange();
    });

    $("input#restricted-hours-switch").bootstrapSwitch({
        state: false,
        size: 'mini'
    });

    $('input#restricted-hours-switch').on('switchChange.bootstrapSwitch', function(event, state) {
        if(state == true) {
            $(this).parent().parent().parent().find('select').prop('disabled', false);
        } else {
            $(this).parent().parent().parent().find('select').prop('disabled', true);
        }
    });

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
                'Today': [moment().format('YYYY/MM/DD HH:MM:SS'), moment().format('YYYY/MM/DD 23:59:59')],
                'Tomorrow': [moment().add(1, 'days'), moment().add(1, 'days')],
                'Next 7 Days': [moment(), moment().add(6, 'days')],
                'Next 30 Days': [moment(), moment().add(29, 'days')],
                'This Month': [moment(), moment().endOf('month')],
                'Next Month': [moment().add(1, 'month').startOf('month'), moment().add(1, 'month').endOf('month')]
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
            "startDate": moment().format('YYYY/MM/DD HH:MM:SS'),
            "endDate": moment().format('YYYY/MM/DD 23:59:59')
        });

        $('input#sms-campaign-valid-datetime').on('apply.daterangepicker', function(ev, picker) {
            console.log(picker.startDate.format());
            console.log(picker.endDate.format());
            console.log(picker.startDate.valueOf());
            console.log(picker.endDate.valueOf());
            console.log(picker.startDate.utc().format());
            console.log(picker.endDate.utc().format());
            console.log(picker.startDate.utc().valueOf());
            console.log(picker.endDate.utc().valueOf());

            $('input#sms_campaign_start_date').val((picker.startDate.utc().valueOf()/1000));
            $('input#sms_campaign_end_date').val((picker.endDate.utc().valueOf()/1000));
        });
    }
});
