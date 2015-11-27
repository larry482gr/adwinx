// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
$(document).ready(function() {
    try {
        var previewNode = document.querySelector("#contact-lists-template");
        previewNode.id = "";
        var previewTemplate = previewNode.parentNode.innerHTML;
        previewNode.parentNode.removeChild(previewNode);
        var processingProgressBar = document.querySelector("#processing-progress #total-progress .progress-bar");

        var dopzoneArea = document.body;
        var dropzoneOptions = {
            url: "/contacts/bulk_import",
            paramName: "contact[contact_lists]",
            thumbnailWidth: 80,
            thumbnailHeight: 80,
            parallelUploads: 20,
            previewTemplate: previewTemplate,
            autoQueue: false,
            previewsContainer: "#previews",
            processingProgressBar: processingProgressBar,
            clickable: ".import-list-button",
            maxFiles: 5,
            maxFilesize: 3,
            acceptedFiles: "text/csv," +
            "text/comma-separated-values," +
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            headers: { "X-CSRF-Token" : $('meta[name="csrf-token"]').attr('content') }
        };

        initializeDropzone(dopzoneArea, dropzoneOptions);
    } catch(_e) {
        console.log(_e);
    }
});
