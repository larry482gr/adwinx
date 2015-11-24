// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
$(document).ready(function(){
    var previewNode = document.getElementById("template");
    previewNode.id = "";
    var previewTemplate = previewNode.parentNode.innerHTML;
    previewNode.parentNode.removeChild(previewNode);

    var myDropzone = new Dropzone(document.body, { // Make the whole body a dropzone
        url: "/target-url", // Set the url
        thumbnailWidth: 80,
        thumbnailHeight: 80,
        parallelUploads: 20,
        previewTemplate: previewTemplate,
        autoQueue: false, // Make sure the files aren't queued until manually added
        previewsContainer: "#previews", // Define the container to display the previews

    });

    myDropzone.on("addedfile", function(file) {
        // Hookup the start button
        file.previewElement.getElementsByClassName("start").onclick = function() { myDropzone.enqueueFile(file); };
    });

// Update the total progress bar
    myDropzone.on("totaluploadprogress", function(progress) {
        document.getElementsByClassName("progress-bar").style.width = progress + "%";
    });

    myDropzone.on("sending", function(file) {
        // Show the total progress bar when upload starts
        document.getElementById("#total-progress").style.opacity = "1";
        // And disable the start button
        file.previewElement.getElementsByClassName("start").setAttribute("disabled", "disabled");
    });

// Hide the total progress bar when nothing's uploading anymore
    myDropzone.on("queuecomplete", function(progress) {
        document.getElementById("total-progress").style.opacity = "0";
    });

// Setup the buttons for all transfers
// The "add files" button doesn't need to be setup because the config
// `clickable` has already been specified.
    document.getElementsByClassName("start").onclick = function() {
        myDropzone.enqueueFiles(myDropzone.getFilesWithStatus(Dropzone.ADDED));
    };
    document.getElementsByClassName("cancel").onclick = function() {
        myDropzone.removeAllFiles(true);
    };
});