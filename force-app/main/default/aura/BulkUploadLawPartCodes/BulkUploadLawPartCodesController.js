({
    readFile : function(component, event, helper) {
        
        helper.showSpinner(component,event); 
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        //console.log(fileInput.files.length);
        
        if(fileInput.files.length == 0) {
            
            //show error message if file is not selected and upload button is clicked
            /*helper.showToast(component, 
                             event, 
                             $A.get("$Label.c.ERRMSG_FILE_NOT_SELECTED"), 
                             $A.get("$Label.c.ERROR_MESSAGE"),
                             'error');
            helper.hideSpinner(component,event); */
            
            component.set("v.approveErrorMessage", 'File not selected, Please select a file');
            document.querySelector("#generalErrorMsgDiv").style.display = 'none';
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#generalErrorMsgDiv").scrollIntoView();
            helper.hideSpinner(component,event);
            return;
        }
        
        var fr = new FileReader();
        var toastEvent = $A.get("e.force:showToast");      
        
        fr.onload = $A.getCallback(function() {
            
            var linesData = fr.result.split("\n");
            var headers = linesData[0].split(",");
            
            console.log(headers);
            console.log(headers.length);
            if(headers.length != 8) {
                
                //Show error message when number of columns in csv != 8
                //helper.showToast(component, event,  "Invalid file selected. Please check the file format." , $A.get("$Label.c.ERROR_MESSAGE"),"error");
                //helper.hideSpinner(component,event); 
                
                component.set("v.approveErrorMessage", 'Invalid file selected. Please check the file format.');
                document.querySelector("#generalErrorMsgDiv").style.display = 'none';
                document.querySelector("#generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#generalErrorMsgDiv").scrollIntoView();
                helper.hideSpinner(component,event);
                return;
            }
            
            if(linesData.length < 2) {
            
                //Show error message if csv does not contain any record
                /*helper.showToast(component, 
                                 event, 
                                 $A.get("$Label.c.ERRMSG_NO_RECORDS_IN_FILE"), 
                                 $A.get("$Label.c.ERROR_MESSAGE"),
                                 'error');
                helper.hideSpinner(component,event); */
                
                component.set("v.approveErrorMessage", 'CSV should contain at least one record.');
                document.querySelector("#generalErrorMsgDiv").style.display = 'none';
                document.querySelector("#generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#generalErrorMsgDiv").scrollIntoView();
                helper.hideSpinner(component,event);
                
                return;
            }
            console.log('linesData = '+linesData);
            console.log('Header Row = '+linesData[0]);
            event.getSource().set("v.disabled", true);
            helper.callServerSideAction(component, event, fr.result, linesData[0]);
        });
        fr.readAsBinaryString(file);
    },
    destroyComponent : function(component, event, helper){
        
        helper.redirectToLPCHome(component, event);
    }
})