({
    doInit : function(component, event, helper) {
        
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        component.set('v.objectionDate', today.getFullYear() + "-" + monthDigit + "-" + today.getDate());
        
        var wasRebateApprovedAction = component.get("c.wasRebateApproved");
        wasRebateApprovedAction.setParams({ 
            tempAssessment : component.get("v.assessmentObj")
        });
        wasRebateApprovedAction.setCallback(this,function(resp) {
            
            var state = resp.getState();           
            if(state === "SUCCESS") {
                
                component.set("v.hasApprovedRebateBeforeLevyEndPeriod", resp.getReturnValue());
            }
        });
        $A.enqueueAction(wasRebateApprovedAction);
        
        helper.checkBSPTSPExistence(component, event);
        helper.instanciateObjectionCase(component, event);
    },
    setObjectionReason : function(component, event, helper) {
        
        console.log(event.target.id);
        component.set("v.objectionReasonOption", event.target.id);
    },
    submitObjection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
           document.querySelector("#levyObjectionComponent #generalErrorMsgDiv").style.display = 'block';
           document.querySelector("#levyObjectionComponent #generalErrorMsgDiv").scrollIntoView();
           return;
        }
        else {
           
           document.querySelector("#levyObjectionComponent #generalErrorMsgDiv").style.display = 'none';
           helper.submitAssessmentObjection(component, event);
        }
    },
    closeObjection : function(component, event, helper) {
         
        console.log('Action Fired');
        helper.closeObjectionWindow(component, event);
    }
})