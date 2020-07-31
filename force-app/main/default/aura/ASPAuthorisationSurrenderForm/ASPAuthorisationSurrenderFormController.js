({
    doInit : function(component, event, helper) {
        console.log('CALLED');
        
    },
    
    cancelForm : function(component, event, helper) {
        var closeSurrenderFormonly = component.getEvent("closeSurrenderFormonly");
        closeSurrenderFormonly.fire();
    },
    
    hideSpinnerOnCancel : function(component, event, helper) {
        helper.hideSpinner(component,event,helper);
    },
    
    createCase : function(component, event, helper) {
        var checkRadio = component.get("v.value");
        var checkCheckbox = component.get('v.checkbox-1');
        
        var recId = component.get('v.record_Id');
        var checkAccountIdAccess = component.get('v.account_Id');
        
        var surrenderDate = component.get("v.surrenderDate");
         helper.showSpinner(component, event);
        console.log('Surrender Event Handler Called');
        var recId = event.getParam('recordId');
        console.log('Got Record Id: '+recId);
        
        var surrenderAction = component.get('c.surrenderAuthorisation');     
        surrenderAction.setParams({
            "authorisationId": recId,
            "surrenderdate" : surrenderDate
        });
        
        surrenderAction.setCallback(this, function(result) {
            
            var state = result.getState();
            
            console.log(state);
            
            if(state === "SUCCESS") {
                
                var returnStr = result.getReturnValue();
                console.log('Return Value: '+returnStr);
               
                
                if(returnStr != '') {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Request #"+returnStr+" to surrender authorisation lodged successfully.",
                        "type": "success",
                        "duration":10000
                    });
                    toastEvent.fire();
                    helper.fetchAuthorisations(component, event);
                  var closeSurrenderForm = component.getEvent("closeSurrenderForm");
                    closeSurrenderForm.fire();   
                }
            }
            else
                console.log('Error from server');
            
            helper.hideSpinner(component, event);
        });
        
        $A.enqueueAction(surrenderAction);
     
      
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
    },
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