({
    doInit : function(component, event, helper) {
        
        console.log('Inside doInit');
        
        helper.fetchAccountDetails(component, event);
        helper.fetchAssessmentList(component, event);
    },
    viewAssessmentDetails : function(component, event, helper) {
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        console.log('Selected Assessment Id: '+recId);
        console.log(component.get("v.assessmentMap")[recId]);
        component.set("v.assessmentRecord", component.get("v.assessmentMap")[recId]);
        
        console.log(component.get("v.assessmentMap"));
        
        $A.util.addClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"),  "slds-backdrop--open");
    },
    closeAssessmentDetails : function(component, event, helper) {
        
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");       
    },
    raiseAnObjection : function(component, event, helper) {
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        console.log('Selected Assessment Id: '+recId);
        console.log(component.get("v.assessmentMap")[recId]);
        
        helper.showSpinner(component, event);
        
        var action = component.get('c.hasOpenObjectionCase');      
        action.setParams({ 
            relatedAssessmentId : recId
        });
        action.setCallback(this, function(result) {
            
            helper.hideSpinner(component, event);
            
            var state = result.getState();
            
            console.log(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                if(result.getReturnValue() == false) {
                    
                    component.set("v.assessmentRecord", component.get("v.assessmentMap")[recId]);
                    $A.util.addClass(component.find("objectionMessageBox"), "slds-fade-in-open");
                    $A.util.addClass(component.find("backdrop"),  "slds-backdrop--open");
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_Open_Objection_Case_Exists"),
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);    

    },
    handleObjectionCancellation : function(component, event, helper) {
        
        component.set("v.assessmentRecord", null);
        $A.util.removeClass(component.find("objectionMessageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");  
    }
})