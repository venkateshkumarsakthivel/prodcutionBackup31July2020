({
    submitRegistration : function(component, event, helper) {
        
        console.log(component.get("v.registrationRecord"));
        helper.submitRegistrationForm(component, event);
    },
    confirmRegistrationSubmission : function(component, event, helper) {
     
         var getProfileNameAction = component.get("c.isConsoleUser");
       
        console.log('output  ' + getProfileNameAction);
        getProfileNameAction.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Sunkara ' + state);
            // Srikanth: JIRA 287 change the pop up message for console users. 
            if(state === "SUCCESS") {
                component.set("v.isConsoleUser",response.getReturnValue());
                console.log('checking ' + component.get("v.isConsoleUser"));
                 helper.showPopupModal(component, event);
             
            }
          
            
        });
        //endDateAction.setBackground();
        $A.enqueueAction(getProfileNameAction); 
       
    }
    
})