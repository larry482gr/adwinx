function validUsername(username) {
    var valid_username = /^[A-Za-z0-9]{6,20}$/i;
    return valid_username.test(username);
}

function validPassword(password) {
    var valid_password = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$/i;
    return valid_password.test(password);
}

function validEmail(email) {
    var valid_email = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]+$/i;
    return valid_email.test(email);
}

function validLettersAndNumbers(string) {
    var valid_let_num = /^[a-zA-Z0-9]+$/;
    return valid_let_num.test(string);
}

function validNumber(number) {
    var valid_number = /^[0-9]+$/;
    return valid_number.test(number);
}

function empty(string) {
    return (string == null || typeof string == 'undefined' || string.length == 0);
}

function validMinLength(string, limit) {
    return string.length > limit;
}

function validMaxLength(string, limit) {
    return string.length < limit;
}

function isInt(value) {
    if (isNaN(value)) {
        return false;
    }
    var x = parseFloat(value);
    console.log(x);
    console.log((x | 0) === x);
    return (x | 0) === x;
}

function escapeRegExp(str) {
    return str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
}

function replaceAll(str, find, replace) {
    return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
}

function submitForm(form, errors) {
    if(errors.length > 0) {
        for(i = 0; i < errors.length; i++) {
            form.find('#error_explanation').remove();

            var resourceArray = form.attr('class').split('_');
            var resource = '';
            for(i = 1; i < resourceArray.length; i++) {
                resource += (resourceArray[i] + ' ').capitalize();
            }
            form.prepend(getErrorsDiv(resource, errors));

            return false;
        }
    } else {
        return true;
    }
}

function getErrorsDiv(resource, errors) {
    errors_list = '';

    for(i = 0; i < errors.length; i++) {
        errors_list += '<li>' + errors[i] + '</li>';
    }

    // TODO put '# errors prohibited...' in translation files.
    return '<div id="error_explanation" class="alert alert-danger" role="alert">' +
        '<h2>' + errors.length + ' errors prohibited this '+ resource +'from being saved:</h2>' +
        '<ul>' +
        errors_list +
        '</ul>' +
        '</div>';
}

// Returns a random number between 0 (inclusive) and 1 (exclusive)
function getRandom() {
    return Math.random();
}

// Returns a random number between min (inclusive) and max (exclusive)
function getRandomArbitrary(min, max) {
    return Math.random() * (max - min) + min;
}

// Returns a random integer between min (included) and max (excluded)
// Using Math.round() will give you a non-uniform distribution!
function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min)) + min;
}

// Returns a random integer between min (included) and max (included)
// Using Math.round() will give you a non-uniform distribution!
function getRandomIntInclusive(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function properLink(page) {
    var protocol = window.location.protocol;
    var host = window.location.host;
    var path = window.location.pathname;
    var params = '';

    params = '?' + additional_fields();
    params = params + search_filters();

    // params += '?limit=' + per_page;
    params += '&page=' + page;

    Turbolinks.visit(protocol + '//' + host + path + params);
}

function additional_fields() {
    var additional_params = '';
    if(typeof $('form.additional-fields') != 'undefined') {
        var check_val = 0;

        $('form.additional-fields div.checkbox-js').each(function(index) {
            check_val = $(this).find('input[type="checkbox"]').is(':checked') ? 1 : 0;
            additional_params += $(this).attr('rel') + '=' + check_val + '&';
        });
    }

    return additional_params;
}

function search_filters() {
    var search_params = '';
    if(typeof $('form.search-filters') != 'undefined') {
        search_params = $('form.search-filters').serialize();
    }

    return search_params;
}

/**
 * Initializes a new Dropzone element.
 * @param {object} dropzoneArea - The area which will be used to drop files. Ex. document.body
 * @param {object} dropzoneOptions - The Dropzone options as defined in http://www.dropzonejs.com/#configuration-options
 */
function initializeDropzone(dropzoneArea, dropzoneOptions) {
    var myDropzone = new Dropzone(dropzoneArea, dropzoneOptions);

    document.querySelector("#processing-progress").style.opacity = "0";

    myDropzone.on("dragover", function(event) {
        // Hookup the start button
        document.querySelector(".drop-area").style.border = "2px solid #5cb85c";
    });

    myDropzone.on("drop", function(event) {
        // Hookup the start button
        document.querySelector(".drop-area").style.border = "1px dashed #888";
        if(!document.querySelector(".drop-area").visible) {
            document.querySelector(".drop-area").style.display = 'block';
        }

    });

    myDropzone.on("dragleave", function(event) {
        // Hookup the start button
        document.querySelector(".drop-area").style.border = "1px dashed #888";
    });

    myDropzone.on("addedfile", function(file) {
        // Hookup the start button
        file.previewElement.querySelector(".start").onclick = function() { myDropzone.enqueueFile(file); };
    });

    // Update the total progress bar
    // myDropzone.on("totaluploadprogress", function(progress) {
    //     document.querySelector("#total-progress .progress-bar").style.width = progress + "%";
    // });

    myDropzone.on("sending", function(file) {
        // Show the total progress bar when upload starts
        document.querySelector("#total-progress .progress-bar").style.width = "0%";
        document.querySelector("#processing-progress").style.opacity = "1";
        // And disable the start button
        file.previewElement.querySelector(".start").setAttribute("disabled", "disabled");
    });

    // Hide the total progress bar when nothing's uploading anymore
    // myDropzone.on("queuecomplete", function(progress) {
    //     document.querySelector("#processing-progress").style.opacity = "0";
    // });

    // Setup the buttons for all transfers
    // The "add files" button doesn't need to be setup because the config
    // `clickable` has already been specified.
    document.querySelector("#actions .start").onclick = function() {
        myDropzone.enqueueFiles(myDropzone.getFilesWithStatus(Dropzone.ADDED));
    };
    document.querySelector("#actions .cancel").onclick = function() {
        myDropzone.removeAllFiles(true);
    };
}
