({
    readFile : function(component, event, helper) {
        
        helper.showSpinner(component,event); 
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        var fr = new FileReader();
        
        console.log(fileInput.files.length);
        
        if(fileInput.files.length == 0){
            //show error message if file is not selected and upload button is clicked
            helper.showToast(component, 
                             event, 
                             $A.get("$Label.c.ERRMSG_FILE_NOT_SELECTED"), 
                             $A.get("$Label.c.ERROR_MESSAGE"),
                             'error');
            helper.hideSpinner(component,event); 
        }

        fr.onload = function() {

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