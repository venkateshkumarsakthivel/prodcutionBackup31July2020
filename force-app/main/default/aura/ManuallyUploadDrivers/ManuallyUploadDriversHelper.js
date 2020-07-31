({
    //close popups 
    closeModalDiv : function(component, event){
        
        $A.util.removeClass(component.find("modalDiv"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        
    },  
    saveDrivrRecord : function(component, event){
        
        console.log('In saveDriverRecord helper');   
        
        //Variable declaration
        var lastName = component.get("v.lastName");
        var dob = component.get("v.dob");
        
        console.log('lastName === '+lastName);
        console.log('dob === '+dob);
        //Input validation
        if(!this.isInputValid(component, event, lastName, dob)) {
            console.log('Input invalid');
            return;
        }
        
        console.log('Input valid');
        
        var licenceNumber = component.get("v.licenceNo");
        
        //register sever side method
        var action = component.get("c.saveSingleDriver");
        
        //set parameters to server side method
        action.setParams({
            "lastName" : lastName,
            "dateOfBirth" : this.formatDateString(dob),
            "licenceNo" : licenceNumber
        });
        
        //server callback function
        action.setCallback(this, function(response){
            
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            
            var state = response.getState();
            console.log('state: '+state);
            if(state == 'SUCCESS'){
                console.log('returnvalue: '+response.getReturnValue());
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
                        "fleetRecordType": 'Driver',
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
                        "type" : "error"
                    }); 
                    toastEvent.fire();
                }
                    else if(response.getReturnValue() == $A.get("$Label.c.INVALID_DATE_MESSAGE")){
                        console.log('State Duplicate record: ');    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": 'Error',
                            "message": $A.get("$Label.c.INVALID_DATE_TOAST_MESSAGE"),
                            "duration":10000,
                            "type" : "error"
                        }); 
                        toastEvent.fire();
                    }
                        else if(response.getReturnValue() == $A.get("$Label.c.INVALID_LAST_NAME")){
                            console.log(response.getReturnValue());    
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": 'Error',
                                "message": $A.get("$Label.c.INVALID_LAST_NAME"),
                                "type" : "error",
                                "duration":10000
                            }); 
                            toastEvent.fire();
                        }
                
                        else if(response.getReturnValue() == $A.get("$Label.c.INVALID_AGE_MESSAGE")){
                            console.log('State Duplicate record: ');    
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": 'Error',
                                "message": $A.get("$Label.c.INVALID_AGE_TOAST_MESSAGE"),
                                "type" : "error",
                                "duration":10000
                            }); 
                            toastEvent.fire();
                        }
            }
            else {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.ERROR_MESSAGE"),
                    "message": response.getReturnValue(),
                    "duration":10000,
                    "type" : "warning"
                }); 
                toastEvent.fire();
                var errorEvent = component.getEvent('createFleetEntity');
                errorEvent.setParams({
                    "fleetRecordType": 'Driver',
                    "status": "Error"
                });
                
                errorEvent.fire();
            }  
            
            
        });
        //enqueue sever side action
        $A.enqueueAction(action);
    },
    
    isInputValid : function(component, event, lastName, dob){
        
        console.log(dob);
        component.find("lastname").set("v.errors", null);
        component.find("dob").set("v.errors", null);
        
        var hasError = false;
        
        var licenceNumregEx = /^(?=[a-zA-Z0-9]*$)(?:.{6}|.{8})$/;
        var lastNameRegEx = /[a-zA-Z ]{1,20}$/;
        
        
        //validate last name of driver
        if(!lastName) {
            
            component.find("lastname").set("v.errors",  [{message: "Invalid Last Name"}]);
            hasError = true;
        }
        
        if(!lastNameRegEx.test(lastName)) {
            
            component.find("lastname").set("v.errors", [{message: "Invalid Last Name"}]);
            hasError = true;
        }
        
        //validate dob of driver
        
        if(!dob) {
            
            component.find("dob").set("v.errors", [{message: "Invalid Birth Date"}]);
            hasError = true;
        }
        
        if(!this.isDOBValid(dob)){
            
            component.find("dob").set("v.errors",  [{message: "Invalid Birth Date"}]);
            hasError = true;
        }
        
        
        if(!this.isAgeValid(dob)){
            
            console.log('Date exceeded');
            var errorMsg = $A.get("$Label.c.Error_Message_Invalid_DOB");
            component.find("dob").set("v.errors",  [{message: errorMsg}]);
            hasError = true;
        }
        
        component.find("licenceNumber").verifyLicence();
        if(component.find("licenceNumber").get("v.isValid") == false)
            hasError = true;
        
        if(hasError)
            return false;
        
        return true;
    },
    
    //format a string compatible to apex controller
    formatDateString : function(dob){
        return dob.substring(8,10) + '/' + dob.substring(5,7) + '/' + dob.substring(0, 4);
    },
    
    isAgeValid : function(birth){
        var birthdate = new Date(birth);
        var today = new Date();
        
        if(birthdate > today){
            return false;
        }
        var timeDiff = Math.abs(today.getTime() - birthdate.getTime());
        var diffInYears = Math.floor((Math.ceil(timeDiff / (1000 * 3600 * 24))/365.242189));
        console.log("AgeDiffrance = ===="+diffInYears); 
        if(diffInYears < 18 || diffInYears >=150){
            return false;
        }
        return true;
    },
    
    
    
    isDOBValid : function (str){
        var datestr = new Date(str);
        if(datestr == 'NaN' || datestr == 'Invalid Date' ){
            return false;
        }
        return true; 
    }
})