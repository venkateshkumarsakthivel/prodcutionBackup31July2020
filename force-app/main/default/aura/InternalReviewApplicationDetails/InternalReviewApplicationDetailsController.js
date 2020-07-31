({
    loadData : function(component, event, helper){
        var aspStatusList 	= ["Granted With Conditions", "Granted Unconditionally", "Suspended", "Cancelled", "Refused"];
        var taxiStatusList 	= ["Suspended", "Cancelled", "Granted"];
        component.set("v.aspStatusList", aspStatusList);
        component.set("v.taxiStatusList", taxiStatusList);
        helper.loadFormDetails(component, event);
    },
    
	toggleSectionContent : function(component, event, helper){       
        helper.toggleSectionContent(component, event);
    },
    
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';        
        helper.resetErrorMessages(component, event);        
    },
    
    saveReviewChanges : function(component, event, helper) {
            
        if(helper.performBlankInputCheck(component, event)) {            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';
            helper.renderNextSection(component, event, false, true);
        } 
    },
    
    saveFormState : function(component, event, helper){
        if(helper.performBlankInputCheck(component, event)) {            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';
            helper.renderNextSection(component, event, true, false);
        } 
    },
    
    renderNextSection : function(component, event, helper) {
        if(helper.performBlankInputCheck(component, event)) { 
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }else {      
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';
            helper.renderNextSection(component, event, false, false);
        }     
    },
    
    cancelForm : function(component, event, helper) {
        console.log('hello this form is going close soon');
        var disableModal = component.getEvent("closeInternalReviewModal");
        disableModal.fire();
    },
     fetchApplicationDetails : function(component, event, helper) {
         if(component.get("v.accountId") != undefined){
         	component.set("v.isConsole",true);
            helper.loadFormDetails(component, event, helper);
         }else{
             if(component.get("v.reviewFormWrpObj.authorisationNumber"))
            	helper.getAuthorisationId(component, event, helper);  
         }
    },
})