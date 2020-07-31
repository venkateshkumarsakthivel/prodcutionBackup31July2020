({
    addNewContact : function(component, event, helper) {
        helper.createNewSupportRequest(component,event);		
    },
    //addNewContact : function(component, event, helper) {
        //helper.addContact(component,event);		
    //},
     confirmAddContact : function(component, event, helper) {
      
        if(!helper.validateInputs(component)) {

           // document.querySelector("#addContactForm #generalErrorMsgDiv").style.display = 'none';
            
            $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "The request will be submitted for review and approval by Point to Point Transport Commission."
                    + "<br/>&nbsp;Do you wish to continue?",
                    "confirmType": "NewContact"
                },
                function(newComponent, status, errorMessage){
                    console.log(status);
                    if (status === "SUCCESS") {                    
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
        //} else {
           // document.querySelector("#addContactForm #generalErrorMsgDiv").style.display = 'block';
           // document.querySelector("#addContactForm #generalErrorMsgDiv").scrollIntoView();
           // return;
        //}
    },
    onKeyUp : function(component, event, helper){
        if (event.getParam('keyCode')===13) {
            helper.createNewSupportRequest(component,event);
        }
    },
    
    closemodal : function(component, event, helper) {
        helper.closemodal(component,event);
    },
    
    contactTypeChange : function(component,event,helper){
        component.find('contactTypeInput').set("v.errors", null);
        
        if(component.get("v.contactType") == "Nominated Director/Manager") {
            component.set("v.isContactTypeNominatedDirector", true);
        } 
        else {
            component.set("v.isContactTypeNominatedDirector", false);
        }
    },
    
    contactRoleChange : function(component,event,helper){
        component.find('contactRoleInput').set("v.errors", null);
    },
    
    familyNameChange : function(component,event,helper){
        component.find('familyNameInput').set("v.errors", null);
    },
    
    firstGivenNameChange : function(component,event,helper){
        component.find('firstGivenNameInput').set("v.errors", null);
    },
    
})