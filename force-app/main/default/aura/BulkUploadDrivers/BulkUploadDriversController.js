({
    readFile : function(component, event, helper) {
        
        helper.showSpinner(component,event); 
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        //console.log(fileInput.files.length);
        if(fileInput.files.length == 0){
            //show error message if file is not selected and upload button is clicked
            helper.showToast(component, 
                             event, 
                             $A.get("$Label.c.ERRMSG_FILE_NOT_SELECTED"), 
                             $A.get("$Label.c.ERROR_MESSAGE"),
                             'error');
            helper.hideSpinner(component,event); 
        }
        
        var fr = new FileReader();
        var toastEvent = $A.get("e.force:showToast");
        
        fr.onload = function() {
            linesData = fr.result.split("\n");
            headers = linesData[0].split(",");
            
            if(headers.length != 3){
                //Show error message when number of columns in csv not 3
                helper.showToast(component, event,  "Invalid file selected. Please check the file format." , $A.get("$Label.c.ERROR_MESSAGE"),"error");
                helper.hideSpinner(component,event); 
                return;
            }
            
            if(linesData.length < 3){
                //Show error message if csv does not contain any record
                helper.showToast(component, 
                                 event, 
                                 $A.get("$Label.c.ERRMSG_NO_RECORDS_IN_FILE"), 
                                 $A.get("$Label.c.ERROR_MESSAGE"),
                                 'error');
                helper.hideSpinner(component,event); 
                return;
            }
            console.log('linesData = '+linesData);
            console.log('Header Row = '+linesData[0]);
            event.getSource().set("v.disabled",true);
            helper.callServerSideAction(component, event, fr.result);
        };
        fr.readAsBinaryString(file);
    },
    
    destroyComponent : function(component, event, helper){
        //console.log("In destroyComponent");
        helper.closeModalDiv(component, event);
    }
})