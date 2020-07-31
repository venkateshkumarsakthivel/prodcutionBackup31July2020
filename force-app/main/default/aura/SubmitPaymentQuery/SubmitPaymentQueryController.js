({

    doInit : function(component, event, helper){
        helper.doInit(component, event);
    },
	renderNextSection : function(component, event, helper) {
	   
	    
	    if(helper.performBlankInputCheck(component, event)) {            
            document.querySelector("#submitqueryPayment #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#submitqueryPayment #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {            
            document.querySelector("#submitqueryPayment #generalErrorMsgDiv").style.display = 'none';
            helper.createCaseRecord(component, event);
        } 
	},
	toggleSectionContent : function(component, event, helper){       
        helper.toggleSectionContent(component, event);
    },
    processCancel : function(component, event, helper) {
        
        if(component.get("v.submitPaymentWrpObj.csObj.Id") == undefined ||
           component.get("v.submitPaymentWrpObj.csObj.Id") == '') {
            
            var disableModal = component.getEvent("closeApplication");
            disableModal.fire();
            
        } else {
            
            var applicationLink = '/manage-profile?src=accountMenu';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
        
    },
})