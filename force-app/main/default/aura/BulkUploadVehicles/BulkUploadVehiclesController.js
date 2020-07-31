({
    readFile : function(component, event, helper) {
        //event.getSource().set("v.disabled",true);
        helper.showSpinner(component,event); 
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        
        if(fileInput.files.length == 0){
            helper.showToast(component, event, 'Please select file', 'Error!', "error");
            helper.hideSpinner(component,event); 
            event.getSource().set("v.disabled",false);
            return;
        }
        
        var fr = new FileReader();
        var toastEvent = $A.get("e.force:showToast");
        
        fr.onload = function() {
            console.log(fr.result);
            linesData = fr.result.split("\n");
            headers = linesData[0].split(",");
            
            for(var i = 0; i < linesData; i++){
                var colValue = linesData[index].split(",");
                if((colValue[0] == '') || (colValue[1] == '') || (colValue[2] == '')){
                    helper.showToast(component, event, 'Invalid file contents. Please check the file contents.', 'Error!',"error");
                    helper.hideSpinner(component,event); 
                    event.getSource().set("v.disabled",false);
                    return;                     
                }
                if((colValue[2].length < 4) || (colValue[2].length > 4) ){
                    helper.showToast(component, event, 'Invalid file contents. Please check the file contents.', 'Error!',"error");
                    helper.hideSpinner(component,event); 
                    event.getSource().set("v.disabled",false);
                    return;
                }
                if((colValue[1] != 'O') || (colValue[1] != 'M') ){
                    helper.showToast(component, event, 'Invalid file contents. Please check the file contents.', 'Error!',"error");
                    helper.hideSpinner(component,event); 
                    event.getSource().set("v.disabled",false);
                    return;
                }
            }
            
            if(headers.length != 3){
                helper.showToast(component, event, 'Invalid file selected. Please check the file format.', 'Error!',"error");
                helper.hideSpinner(component,event); 
                event.getSource().set("v.disabled",false);
                return;
            }
            
            if(linesData.length < 3){
                helper.showToast(component, event, 'CSV should contain at least one record', 'Error!',"error");
                helper.hideSpinner(component,event); 
                event.getSource().set("v.disabled",false);
                return;
            }
            
            console.log('linesData = '+linesData);
            console.log('headerRow = '+linesData[0]);
            
            helper.callServerSideAction(component, event, fr.result);
        };
        fr.readAsBinaryString(file);
    },
    
    destroyComponent : function(component, event, helper){
        //console.log("In destroyComponent");
        helper.destroyComponent(component, event);
    }
    
})