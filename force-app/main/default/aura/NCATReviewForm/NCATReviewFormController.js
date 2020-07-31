({
    doInit : function(component, event, helper) {
        console.log('Inside doInit');
        helper.showSpinner(component, event);
        var aspStatusList = ["Decision Pending","Granted With Conditions","Granted Unconditionally","Lapsed","Suspended","Cancelled","Refused","Granted"];
        component.set("v.aspStatusList", aspStatusList);
        var taxiStatusList = ["Decision Pending","Granted With Conditions","Granted Unconditionally","Lapsed","Suspended","Cancelled","Refused","Granted"];
        component.set("v.taxiStatusList", taxiStatusList);
        helper.validateUser(component,event);
        component.set("v.ncatReviewCase.Has_there_been_an_internal_review__c", true);
    },
    
    saveNcatReviewCase : function(component, event, helper){
        //console.log('Creating new Case');
        if(!helper.validateInputs(component, event)) {
            helper.hideSpinner(component, event);
            document.querySelector("#NcatReviewForm #generalErrorMsgDiv").style.display = 'none';
            
            console.log('in validateInputs');
            helper.saveNcatReviewCaseData(component, event);
        }
        else {
            console.log('validation error occured');
            document.querySelector("#NcatReviewForm #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#NcatReviewForm #generalErrorMsgDiv").scrollIntoView();
            return;
        }
    },
    
    isInternalReviewChange : function(component, event, helper) {
        
        var selected = event.target.id;
        if(selected == "Internal-Review-Yes") {
            component.set("v.ncatReviewCase.Has_there_been_an_internal_review__c", true);
            component.set("v.internalReviewChecked", "Yes");
        }
        else {
            
            component.set("v.ncatReviewCase.Has_there_been_an_internal_review__c", false);
            component.set("v.internalReviewChecked", "No");
        }
    },
    
    validateDateOfDecisionReviewedAtNCAT: function(component, event, helper) {
        
        //Checking date should not be future date
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.ncatReviewCase.Date_of_decision_being_reviewed_at_NCAT__c") != '' && component.get("v.ncatReviewCase.Date_of_decision_being_reviewed_at_NCAT__c") > todayFormattedDate){
            component.set("v.ncatdateValidationError" , true);
            
        }else {
            component.set("v.ncatdateValidationError" , false);
            
        }
        
    },
    
    validateDateOfInternalReviewDecision : function(component, event, helper) {
        
        //Checking date should not be future date
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        
        if(component.get("v.ncatReviewCase.Date_of_Internal_Review_Decision__c") != '' && component.get("v.ncatReviewCase.Date_of_Internal_Review_Decision__c") > todayFormattedDate){
            
            component.set("v.internalReviewdateValidationError" , true);
        }else {
            
            component.set("v.internalReviewdateValidationError" , false);
        }
        
    },
    
    
})