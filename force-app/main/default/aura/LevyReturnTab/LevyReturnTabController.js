({
	doInit : function(component, event, helper) {
      
        console.log('Inside doInit');
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        var today = new Date();
		var returnDate = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        component.set('v.returnLastDate', returnDate.getDate() + '-' + months[returnDate.getMonth()] + '-'+ returnDate.getFullYear()) ;
        
        var levyEndDateForApprovedRebate  = new Date(returnDate.getFullYear(), returnDate.getMonth(), 0);
		var levyStartDateForApprovedRebate = new Date(levyEndDateForApprovedRebate.getFullYear() - 1, levyEndDateForApprovedRebate.getMonth() + 1, 1);
        component.set('v.levyStartDateForApprovedRebate', levyStartDateForApprovedRebate.getDate() + '-' + months[levyStartDateForApprovedRebate.getMonth()] + '-'+ levyStartDateForApprovedRebate.getFullYear());
        component.set('v.levyEndDateForApprovedRebate', levyEndDateForApprovedRebate.getDate() + '-' + months[levyEndDateForApprovedRebate.getMonth()] + '-'+ levyEndDateForApprovedRebate.getFullYear());
        helper.fetchAccountDetails(component, event);
        helper.validateReturnAction(component, event);
    },
    registerLevy : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL"); 
        urlEvent.setParams({ "url": "/levy-registration?src=levyMenu" }); 
        urlEvent.fire();
    },
    submitReturn : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)
           ||helper.performSpecifiedInputCheck(component, event)) {
           
            document.querySelector("#levyReturnComponent #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#levyReturnComponent #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
           
           document.querySelector("#levyReturnComponent #generalErrorMsgDiv").style.display = 'none';
           helper.submitLevyReturn(component, event);
        }
    },
    editReturn : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.assessmentObj.Privacy_Declaration__c", false);
        window.scrollTo(0, 0);
    },
    cancelReviewEdit : function(component, event, helper) {
        component.set("v.readOnly", true);
        helper.fetchAccountDetails(component, event);
        helper.validateReturnAction(component, event);
        window.scrollTo(0, 0);
    },
    validateBspCount : function(component, event, helper) {
      
        helper.validateSpecifiedBspCount(component, event);
    },
    validateTspCount : function(component, event, helper) {
      
        helper.validateSpecifiedTspCount(component, event);
    }      
})