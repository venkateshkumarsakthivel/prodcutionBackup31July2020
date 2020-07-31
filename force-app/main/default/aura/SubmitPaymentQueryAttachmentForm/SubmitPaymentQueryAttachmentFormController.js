({
	submitQuery : function(component, event, helper) {
	    if(helper.performBlankInputCheck(component, event)) {            
            document.querySelector("#submitPaymentQueryAttch #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#submitPaymentQueryAttch #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {            
            document.querySelector("#submitPaymentQueryAttch #generalErrorMsgDiv").style.display = 'none';
            helper.submitQuery(component, event);
        } 
	},
    
   onPreviousClick : function(component, event, helper){
        if(component.get("v.readOnly") == true) {
            var _nextSectionEvent = component.getEvent("loadSection");
            _nextSectionEvent.setParams({
                "sectionNameToRender": "Customer Enquiry Details",
                "submitPaymentWrpObj": component.get("v.submitPaymentWrpObj"),
                "readOnly": component.get("v.readOnly")
            });
            _nextSectionEvent.fire();          
        } else {
            helper.confirmPrevSection(component, event);
        }
    },
    
    renderPrevSection : function(component, event, helper) {
        var _nextSectionEvent = component.getEvent("loadSection");
        _nextSectionEvent.setParams({
            "sectionNameToRender": "Customer Enquiry Details",
            "submitPaymentWrpObj": component.get("v.submitPaymentWrpObj"),
            "readOnly": component.get("v.readOnly")
        });
        _nextSectionEvent.fire();          
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