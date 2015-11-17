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