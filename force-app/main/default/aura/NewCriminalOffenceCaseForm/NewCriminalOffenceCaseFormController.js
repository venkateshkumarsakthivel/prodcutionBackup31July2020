({

    doInit: function(component, event, helper) {
        helper.isAuthorisedUser(component,event);
       
        var recordTypeId = $A.get("$Label.c.Record_Type_Criminal_Offence_Id");   
        component.set("v.recordType",recordTypeId);  
        component.set("v.editFormVisible",true);
    },

    onRender: function(component, event, helper) {
        helper.isValidParentCase(component,event);
    },
    
    handleSubmitCase: function(component, event, helper) {
        
        event.preventDefault();
        document.querySelector("#CriminalOffenceCaseInformation #generalErrorMsgDiv").style.display = 'none';
        document.querySelector("#CriminalOffenceCaseInformation #accountErrorMsgDiv").style.display = 'none';
        document.querySelector("#CriminalOffenceCaseInformation #licenceErrorMSgDiv").style.display = 'none';
        document.querySelector("#CriminalOffenceCaseInformation #chargeCodeErrorMsgDiv").style.display = 'none';
        document.querySelector("#CriminalOffenceCaseInformation #offenceCodeErrorMsgDiv").style.display = 'none';

        helper.validateFieldValues(component,event);
        
        if(component.get("v.isAllValid")==true){
            helper.submitCase(component,event);
        }
    },


    handleRecordUpdated: function(component, event, helper) {
      
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           // record is loaded (render other component which needs record data value)
            ///console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },

    showRequiredFields: function(component, event, helper){
        $A.util.removeClass(component.find("spinner"), "slds-show");
        $A.util.addClass(component.find("spinner"), "slds-hide");
        $A.util.removeClass(component.find("Submit"), "slds-hide");
        $A.util.removeClass(component.find("Cancel"), "slds-hide");
        $A.util.removeClass(component.find("accountName"), "none");
        $A.util.removeClass(component.find("chargeCode"), "none");
        $A.util.removeClass(component.find("offenceCode"), "none");
        $A.util.removeClass(component.find("decision"), "none");
        $A.util.removeClass(component.find("decisionReason"), "none");
        $A.util.removeClass(component.find("lawPartCode"), "none");
   },

   closeMessageBox : function(component, event, helper) {
        component.set("v.editFormVisible",false); 
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        $A.get("e.force:closeQuickAction").fire();
        
    },
    openMessageBox : function(component, event, helper) {
        component.set("v.editFormVisible",true); 
       
        $A.util.addClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"),  "slds-backdrop--open");
       
        helper.isAuthorisedUser(component,event);
        helper.isValidParentCase(component,event);
        

        var recordTypeId = $A.get("$Label.c.Record_Type_Criminal_Offence_Id");   
        component.set("v.recordType",recordTypeId); 

    },

    handleSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log('Created case Id=='+payload.id);
        console.log('**********CaseNumber=='+payload.fields.CaseNumber.value);

        var toastEvent = $A.get("e.force:showToast");               
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Charge Case # " + payload.fields.CaseNumber.value + " created successfully.",
                        "type": "success",
                        "duration": "500"
                    });
        toastEvent.fire(); 

        
        component.set("v.editFormVisible",false); 
       
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        

        window.setTimeout(
            $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },

    handleError: function(component, event) {
        var errors = event.getParams();
        console.log("Error response**", JSON.stringify(errors));
        console.log("errors.message==**", errors.message);
        var toastEvent = $A.get("e.force:showToast");               
                    toastEvent.setParams({
                        "title": "Error occured!",
                        "message": errors.message,
                        "type": "error",
                        "duration": "10000"
                    });
        toastEvent.fire(); 
        //$A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        //$A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
    },

    
    handleCancel: function(component,event,helper){
        event.preventDefault();
        component.set("v.editFormVisible",false); 
        
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
    }

    
})