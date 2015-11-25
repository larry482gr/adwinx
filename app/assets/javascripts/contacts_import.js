// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
$(document).ready(function(){
    var previewNode = document.querySelector("#template");
    previewNode.id = "";
    var previewTemplate = previewNode.parentNode.innerHTML;
    previewNode.parentNode.removeChild(previewNode);

    var myDropzone = new Dropzone(document.body, { // Make the whole body a dropzone
        url: "/contacts/bulk_import", // Set the url
        paramName: "contact[contact_lists]",
        thumbnailWidth: 80,
        thumbnailHeight: 80,
        parallelUploads: 20,
        previewTemplate: previewTemplate,
        autoQueue: false, // Make sure the files aren't queued until manually added
        previewsContainer: "#previews", // Define the container to display the previews
        clickable: ".fileinput-button", // Define the element that should be used as click trigger to select files.
        maxFiles: 5,
        maxFilesize: 3,
        acceptedFiles: "text/csv, application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        headers: { "X-CSRF-Token" : $('meta[name="csrf-token"]').attr('content') }
    });

    myDropzone.on("dragover", function(event) {
        // Hookup the start button
        document.querySelector(".drop-area").style.border = "2px solid #5cb85c";
    });

    myDropzone.on("drop", function(event) {
        // Hookup the start button
        document.querySelector(".drop-area").style.border = "1px dashed #888";
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
    myDropzone.on("totaluploadprogress", function(progress) {
        // document.querySelector("#total-progress .progress-bar").style.width = progress + "%";
    });

    myDropzone.on("sending", function(file) {
        // Show the total progress bar when upload starts
        // document.querySelector("#total-progress").style.opacity = "1";
        // And disable the start button
        file.previewElement.querySelector(".start").setAttribute("disabled", "disabled");
    });

    // Hide the total progress bar when nothing's uploading anymore
    myDropzone.on("queuecomplete", function(progress) {
        // document.querySelector("#total-progress").style.opacity = "0";
    });

    // Setup the buttons for all transfers
    // The "add files" button doesn't need to be setup because the config
    // `clickable` has already been specified.
    document.querySelector("#actions .start").onclick = function() {
        myDropzone.enqueueFiles(myDropzone.getFilesWithStatus(Dropzone.ADDED));
    };
    document.querySelector("#actions .cancel").onclick = function() {
        myDropzone.removeAllFiles(true);
    };
});