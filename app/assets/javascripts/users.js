$(document).ready(function(){
    $('#user-metadata').tagsinput({
        tagClass: 'tag label label-primary',
        confirmKeys: [13, 32, 44],
        maxTags: 20,
        trimValue: true
    });
});