({
    doInit : function(component, event, helper) {
        var auth = component.get('v.record_Id');
        var radioGroup = component.find("radioGroupResult");
        var validateAuthorisationAction = component.get("c.getAuthorisationPaymentCalculation");
        validateAuthorisationAction.setParams({
            "authId": auth
        });
        validateAuthorisationAction.setCallback(this,function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                if (result[0]=== '0'){
                    var closeSurrenderForm = component.getEvent("closeSurrenderForm");
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "No Pending/Uncleared/Due Orders found on this Authorisation.",
                        "duration":5000,
                        "type": "error"
                    });
                }
                else{
                    var res = response.getReturnValue();
                    component.set("v.OrderCount", res[0]);
                    component.set("v.TotalDueAmount", res[1]);
                    component.set('v.HasPendingOrders', true);
                    
                }
            }
            console.log(state);
        });
        $A.enqueueAction(validateAuthorisationAction);
    },
    
    cancelForm : function(component, event, helper) {
        var closeSurrenderFormonly = component.getEvent("closeSurrenderFormonly");
        closeSurrenderFormonly.fire();
    },
    
    hideSpinnerOnCancel : function(component, event, helper) {
        helper.hideSpinner(component,event,helper);
    },
    
    createCase : function(component, event, helper) {
        //var checkRadio = component.get("v.value");
        var checkCheckbox = component.get('v.checkbox-1');
        //var a = component.get('v.PlatesReturned');
        /*
        if(checkRadio == "true"){
            var a = component.get('v.PlatesReturned');
            component.set('v.PlatesReturned',true);
            var b = component.get('v.PlatesReturned');
        }
        else{
            var a = component.get('v.PlatesReturned');
            component.set('v.PlatesReturned',false);
            var b = component.get('v.PlatesReturned');
        }
        */
       // var b = component.get('v.PlatesReturned');
        var auth = component.get('v.record_Id');
        var checkAccountIdAccess = component.get('v.account_Id');
        
        var surrenderDate = component.get("v.surrenderDate");
        
        if(checkAccountIdAccess != ''){
            var validateAuthorisationAction = component.get("c.createSurrenderCaseFromAgentPortal");
            validateAuthorisationAction.setParams({
                "authId": auth
                
            });
            validateAuthorisationAction.setCallback(this,function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var result = response.getReturnValue();
                    var closeSurrenderForm = component.getEvent("closeSurrenderForm");
                    closeSurrenderForm.fire();
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Your request #"+result+ " has been successfully submitted",
                        "duration":5000,
                        "type": "success"
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(validateAuthorisationAction);
        }
        else{
            var validateAuthorisationAction = component.get("c.createTaxiLicenceSurrenderCaseFromPortal");
            validateAuthorisationAction.setParams({
                "authId": auth,
               "surrenderdate" : surrenderDate
            });
            validateAuthorisationAction.setCallback(this,function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var result = response.getReturnValue();
                    if(result == null){
                        var closeSurrenderForm = component.getEvent("closeSurrenderForm");
                        closeSurrenderForm.fire();
                        console.log('SurrenderCaseExists');
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "message": "A Surrender Application is already requested.",
                            "duration":5000,
                            "type": "error"
                        });
                        toastEvent.fire();
                    }else{
                        var closeSurrenderForm = component.getEvent("closeSurrenderForm");
                        closeSurrenderForm.fire();
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Success",
                            "message": "Your request #"+result+ " has been successfully submitted",
                            "duration":5000,
                            "type": "success"
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(validateAuthorisationAction);
        }
    },
     dateChange : function(component, event, helper) {
        
        var surrenderDate = component.get("v.surrenderDate");
       // var surrenderDate1 = component.find("DateTime").get("v.value");
        console.log('Surrender date is '+ surrenderDate);
        
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
       console.log(today);
      
        if(surrenderDate < today)
            {
            console.log('Surrender date is in the past');
           var toastEvent2 = $A.get("e.force:showToast");           	
            toastEvent2.setParams({
                "message": "Please select the future surrender date.",
                "duration":5000,
                "type": "error"
            });
            toastEvent2.fire();
            return; 
           
        }
		
		 },
    submitSurrenderForm : function(component, event, helper) {
        var checkRadio = component.get("v.value");
        var checkCheckbox = component.get('v.checkbox-1');
        var surrenderDate = component.get("v.surrenderDate");
       // var surrenderDate1 = component.find("DateTime").get("v.value");
        console.log('Surrender date is '+ surrenderDate);
        //console.log(surrenderDate1);
        //console.log(date.valueOf(surrenderdate));
         if(surrenderDate == null || surrenderDate == undefined){
            console.log('Date is not entered');
           var toastEvent1 = $A.get("e.force:showToast");           	
            toastEvent1.setParams({
                "message": "Please select the surrender date.",
                "duration":5000,
                "type": "error"
            });
            toastEvent1.fire();
            return; 
           
        }
       var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
       console.log(today);
      
        if(surrenderDate < today)
            {
            console.log('Surrender date is in the past');
           var toastEvent2 = $A.get("e.force:showToast");           	
            toastEvent2.setParams({
                "message": "Please select the future surrender date.",
                "duration":5000,
                "type": "error"
            });
            toastEvent2.fire();
            return; 
           
        }
        /*
        if(checkRadio == 'none'){
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "message": "Please select whether the plates have been returned to Service NSW or not.",
                "duration":5000,
                "type": "error"
            });
            toastEvent.fire();
            return;
        }
        */
       
        if(checkCheckbox === true){
            var auth = component.get('v.record_Id');
            $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "This notice will be submitted to the Point to Point Commission for finalisation."
                    + "<br/>&nbsp;Do you wish to continue?",
                    "confirmType": "NewSurrenderCaseCreation",
                    "recordId" : auth
                },
                function(newComponent, status, errorMessage){
                    console.log(status);
                    if (status === "SUCCESS") {
                        helper.showSpinner(component,event,helper);
                        component.set("v.body", newComponent);                    
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.");
                        // Show offline error
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }                
                }
            );
        }
        else{
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "Please accept the declaration.",
                "duration":5000,
                "type": "error"
            });
            toastEvent.fire();
        }
    },
    /*
    onGroup: function(component, event, helper) {
        var selected = event.getSource().get("v.label");
        console.log(selected);
        var resultCmp = component.find("radioGroupResult");
        resultCmp.set("v.value", selected);
    },
    handleChange: function (component, event, helper) {
        var changeValue = event.getParam("value");
        console.log(changeValue);
        var resultCmp = component.find("radioGroupResult");
        resultCmp.set("v.value", changeValue);
    }, */
    clickCheckbox: function(component, event, helper){
        console.log('From'+event.target.id);
        var getCheckbox = event.target.id;
        if  (getCheckbox === 'checkbox-1'){
            var a = component.get('v.checkbox-1');
            console.log('before'+a);
            if(a === false){
                component.set('v.checkbox-1',true);
            }
            else{
                component.set('v.checkbox-1',false);
            }
            var b = component.get('v.checkbox-1');
            console.log('after'+b);
        }
    }
})