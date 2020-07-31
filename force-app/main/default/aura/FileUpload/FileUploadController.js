({

    doInit : function (component, event, helper) {

    },
    handleUpload : function(component, event, helper) {
        var _files = event.target.files;
        var _file = _files[0];

        /* validate if selected file validates against file size restrictions. */
        if(helper.MAX_FILE_SIZE < _file.size)  {
        		console.log("validate success, file size is greater than allowed file size");
        		return;
        }

        /* if file pass through file size restrictions proceed to upload as attachment. */
        var _fileReader = new FileReader();
        var _self = this;

        _fileReader.onload = function() {
        		console.log("_fileReader.onload start");
        		var _contents = _fileReader.result;
            	console.log('_fileReader.onload before helper.attach');
        		var _action = helper.attach(component, event, _file, _contents);
	            console.log("_fileReader.onload end Result :: " + _action);
        };
        
    		_fileReader.readAsBinaryString(_file);
    }
})