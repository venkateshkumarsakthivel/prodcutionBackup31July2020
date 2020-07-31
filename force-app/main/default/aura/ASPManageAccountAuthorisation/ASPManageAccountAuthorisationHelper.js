({
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    
    fetchAuthorisations : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountAction = component.get('c.getLoggedInUserAccount');        
        accountAction.setCallback(this, function(result) {
            var act = JSON.parse(result.getReturnValue());
            console.log('Account details on authorisation');
            console.log(act);
            component.set('v.accName', act.Name);
            component.set('v.customerNumber', act.Customer_Number__c);
            
            var action = component.get('c.getAuthorisationRecords');        
            action.setCallback(this, function(result) {
                
                var state = result.getState();
                
                if(state === "SUCCESS") {
                    console.log('result of authorisation');
                    console.log(result.getReturnValue());
                    component.set('v.authorisationList', result.getReturnValue());
                    this.hideSpinner(component, event);
                }
                else {
                    
                    console.log('Error from server');
                    this.hideSpinner(component, event);
                }
            });
            
            $A.enqueueAction(action);
        });
        
        $A.enqueueAction(accountAction); 
    },
    
    fetchNotifiableOccurrences : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountAction = component.get('c.getLoggedInUserAccount');        
        accountAction.setCallback(this, function(result) {
            var act = JSON.parse(result.getReturnValue());
            console.log('Account details on authorisation');
            console.log(act);
            component.set('v.accName', act.Name);
            component.set('v.customerNumber', act.Customer_Number__c);
            
            var action = component.get('c.getNotifiableOccurrencesRecords');        
            action.setCallback(this, function(result) {
                
                var state = result.getState();
                
                if(state === "SUCCESS") {
                    console.log('result of NotifiableOccurrences');
                    console.log(result.getReturnValue());
                    component.set('v.notifiableOccurrencesList', result.getReturnValue());
                    this.hideSpinner(component, event);
                }
                else {
                    
                    console.log('Error from server');
                    this.hideSpinner(component, event);
                }
            });
            
            $A.enqueueAction(action);
        });
        
        $A.enqueueAction(accountAction); 
    },
    
    launchInteralReviewAppForm : function(component, event){
    
        console.log('Launch launchInteralReviewAppForm form');
        var recId;
        var selectedRadioButton = document.getElementsByClassName('radio');
        var recordSelected = false;
               
        for (var i=0; i<selectedRadioButton.length; i++) {
            if (selectedRadioButton[i].checked) {
                recordSelected = true;
                recId = selectedRadioButton[i].getAttribute("data-RecId");
            }
        }
       
        $A.createComponent(
            "c:InternalReviewApplicationForm",
            {
                "record_Id": recId,
                "portalContextName":"ASP",
                "sectionNameToRender":"Internal Review Application Detail"
            },
            function(newComponent, status, errorMessage) {
                
                console.log(status);
                //Add the new button to the body array
                if(status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set('v.body',body);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }  
            }
        );
    },
    
    deselectRecord : function(){
        var selectedRadioButton = document.getElementsByClassName('radio');
        for (var i=0; i<selectedRadioButton.length; i++) {
            if (selectedRadioButton[i].checked) {
                selectedRadioButton[i].checked = false;
            }
        }
    }
    
})