({
    //close popups
    closeModalDiv : function(component, event) {
        $A.util.removeClass(component.find("modalDiv"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        //$A.get('e.force:refreshView').fire();
    },
    saveVehicleRecord : function(component, event){
        
        //variable declaration
        console.log('Save start');
        var plateNumber = component.find("platenumber").get("v.value");
        var plateType = component.find("platetype").get("v.value");
        var chassisNumber = component.find("chassisnumber").get("v.value");
        
        //Input validation
        if(!this.isInputValid(component, event, plateNumber, plateType, chassisNumber)){
            console.log('input invalid');
            return;
        }
        console.log('input valid');
        //server side action registration
        var action = component.get("c.saveSingleVehicle");
        
        //set parameters to server side controller
        action.setParams({
            "plateNumber" : plateNumber,
            "plateType" : plateType,
            "chassisNumber" : chassisNumber
        });
        
        //server callback function
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state returned : '+response.getReturnValue());
            var toastEvent = $A.get("e.force:showToast");
            
            if(state == "SUCCESS"){
                if(response.getReturnValue() === $A.get("$Label.c.SUCCESS_MESSAGE")){  
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.SUCCESS_MESSAGE"),
                        "message": response.getReturnValue(),
                        "duration":10000,
                        "type" : "success"
                    });
                    toastEvent.fire();
                    var successEvent = component.getEvent('createFleetEntity');
                    successEvent.setParams({
                        "fleetRecordType": 'Vehicle',
                        "status": "Success"
                    });
                    console.log('Firing create Fleet Entity Success Event');
                    successEvent.fire();
                    this.closeModalDiv(component, event);
                }
                else if(response.getReturnValue() === $A.get("$Label.c.ERRMSG_DUPLICATE_RECORD_FOUND")){
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.ERROR_MESSAGE"),
                        "message": response.getReturnValue(),
                        "duration":10000,
                        "type" : "error"
                    }); 
                    toastEvent.fire();
                }
            }
            else{
                toastEvent.setParams({
                    "title": $A.get("$Label.c.ERROR_MESSAGE"),
                    "message": response.getReturnValue(),
                    "duration":10000,
                    "type" : "error"
                }); 
                toastEvent.fire();
                var errorEvent = component.getEvent('createFleetEntity');
                errorEvent.setParams({
                    "fleetRecordType": 'Vehicle',
                    "status": "Error"
                });
                console.log('Firing Error Event for Create Fleet Entity');
                errorEvent.fire();
            }  
            
        });
        //enqueue server side action
        console.log('enqueue');
        $A.enqueueAction(action);
        console.log('enqueue end');
    },
    //validate inputs
    isInputValid : function(component, event, plateNumber, plateType, chassisNumber){
        
        component.find("platenumber").set("v.errors", null);
        component.find("platetype").set("v.errors", null);
        component.find("chassisnumber").set("v.errors", null);
        
        var hasError = false;
        var plateNumRegEx = /^[a-zA-Z0-9]{1,6}/;
        var VINRegEx = /^[a-zA-Z-0-9]{4}/;
        
        //validate plate number
        if(!plateNumber){
            
            component.find("platenumber").set("v.errors", [{message: "Invalid Plate Number"}]);
            hasError = true;
        }
        else if(!plateNumRegEx.test(plateNumber)){
            
            component.find("platenumber").set("v.errors", [{message: "Invalid Plate Number"}]);
            hasError = true;
        }

        //validate chasis number
        if(!chassisNumber) {
            
            component.find("chassisnumber").set("v.errors", [{message: "Invalid VIN or Chassis #"}]);
            hasError = true;    
        }
        else if(!VINRegEx.test(chassisNumber)){
            
            component.find("chassisnumber").set("v.errors", [{message: "Invalid VIN or Chassis #"}]);
            hasError = true;
        }
        
        if(hasError)
            return 0;
        return 1;
    }
})