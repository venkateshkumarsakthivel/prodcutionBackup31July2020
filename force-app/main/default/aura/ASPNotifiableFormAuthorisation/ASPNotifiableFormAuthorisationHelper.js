({ 
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner1");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner1");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    
    datetimeError : function(component, event){
        var toastEvent = $A.get("e.force:showToast");           	
        toastEvent.setParams({
            "message": "Please enter valid date/time inputs.", 
            "type": "error",
            "duration":4000,
            "mode" : "pester"
        });
        toastEvent.fire()
        
    },
    
    getAuthorisation : function(component,event) {
        
        var fetchedRecordId = component.get('v.record_Id');
        
        var auth = component.get("c.getAuthorisation");
        auth.setParams({ 'authorisationId' : fetchedRecordId });
        
        auth.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('State is:'+state);
                component.set('v.selectedAuthorization',JSON.parse(response.getReturnValue()));
            }
            else if (state === "INCOMPLETE") {
                console.log(Incomplete);
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log(errors);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    }
                    else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(auth);
        
        var loggedInUserContact = component.get("c.getLoggedInUserContact");
        loggedInUserContact.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.loggedInContactDetails',JSON.parse(response.getReturnValue()));
                console.log('Logged In Contact State is:'+state);
            }
            else if (state === "INCOMPLETE") {
                console.log(Incomplete);
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log(errors);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    }
                    else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(loggedInUserContact);
        
    },
    
    resetErrorMessages : function(component, event) {
        
        component.find("DateTimeValue").set("v.errors", null);
        component.find("fullOccerrenceDescription").set("v.errors", null);
        component.find("contributingFactors").set("v.errors", null);
        component.find("followUpDescription").set("v.errors", null);
        document.getElementById("CovidReturnError").innerHTML = '';
    },
    
    validateBlankInputs : function(component, event, inputId) {
        
        var inputValue = component.find(""+inputId).get('v.value');
        console.log('Got Input Value: ');
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            component.find(""+inputId).set("v.errors", null);
        }
        
        return false;
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName, msg){
        
        var inputValue = component.get('v.'+attributeName);
        if(inputValue == undefined || inputValue == false){
            
            document.getElementById(inputId).innerHTML = msg;
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        return false;
    },
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        var hasRequiredInputsMissing = false;
        /*
        //For DataSan Address Lookup:
            component.find("Postal-Address-Input").validateAddress();
            if(!component.find("Postal-Address-Input").get('v.isValidAddress'))
                 hasRequiredInputsMissing = true;
             */
        //var covidresponse= component.get('v.NoCovidResponse');
         if(this.validateBlankRadioInputs(component, event, "CovidReturnError", "NoCovidResponse",$A.get("$Label.c.Error_Message_Required_Input")))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "DateTimeValue"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "BecameAwareDateTimeValue"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "fullOccerrenceDescription"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "contributingFactors"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "followUpDescription"))
            hasRequiredInputsMissing = true;
        
         if(this.validateBlankInputs(component, event, "state"))
            hasRequiredInputsMissing = true;
        
       //if(this.validateBlankInputs(component, event, "street"))
          //  hasRequiredInputsMissing = true;
        
      // if(this.validateBlankInputs(component, event, "city"))
           // hasRequiredInputsMissing = true;
        
        //if(this.validateBlankInputs(component, event, "state"))
         //  hasRequiredInputsMissing = true;
        
        //if(this.validateBlankInputs(component, event, "postalcode"))
           // hasRequiredInputsMissing = true;
        
        
        console.log("Validation Result: "+hasRequiredInputsMissing);
        
        return hasRequiredInputsMissing;
    }
    
})