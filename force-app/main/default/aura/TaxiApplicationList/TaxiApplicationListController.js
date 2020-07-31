({
    doInit : function(component, event, helper) {
        console.log('initializing the list of applications');
        console.log("In handler refresh");
        helper.showSpinner(component, event);
        helper.retrieveApplicationList(component, event);        
    },    
    withdrawApplication: function(component, event, helper){
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        var caseStatus = event.currentTarget.getAttribute("data-Status");
        helper.withdrawApplication(component,helper,recId,caseStatus);
    },
    createNewApplication : function(component, event, helper){
        console.log('creating a new application for ASP');
        helper.showSpinner(component, event);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/taxi-wat-application?src=myApplicationMenu"
        });
        urlEvent.fire();   
        helper.hideSpinner(component, event); 
    },
    navigateToApplication : function(component, event, helper){
        
        console.log('navigating to application');
        var recId = event.currentTarget.getAttribute("data-RecId");
        var applicationStatus = event.currentTarget.getAttribute("data-Status");
        var isClosed = event.currentTarget.getAttribute("data-isClosed");
        var isWAT = event.currentTarget.getAttribute("data-isWAT");
        var applicationSubStatus = event.currentTarget.getAttribute("data-Sub-Status");
        var applicationSubType = event.currentTarget.getAttribute("data-Sub-Type");
        
        console.log('recId ' + recId);
        console.log('applicationSubType ' + applicationSubType);
        console.log('Status ' + applicationStatus);
        console.log('Sub Status ' + applicationSubStatus);
        console.log('Is Closed ' + isClosed);
        console.log('Is WAT ' + isWAT);
        var urlEvent = $A.get("e.force:navigateToURL");
        
        if(applicationSubType == "Renewal Application") {
            
            var applicationLink = '/taxi-resume-renewal-application?src=myApplicationMenu&appId='+recId+'&appSubStatus='+applicationStatus;
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
        if(applicationSubType == "Transfer - Owner") {
            
            var applicationLink = '/taxi-transfer?appId='+recId+'&appStatus='+applicationStatus;
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
        if(isWAT == "false" && isClosed == "false" 
           && (applicationStatus == "Draft" || applicationStatus == "New")
           && (applicationSubStatus == null || applicationSubStatus == "" || applicationSubStatus == "Draft")) {
            var applicationLink = '/taxi-applications?src=myApplicationMenu&appId=' + recId;
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
        else if(isWAT == "true" && isClosed == "false" 
                && (applicationStatus == "Draft" || applicationStatus == "New")
                && (applicationSubStatus == "" || applicationSubStatus == "Draft")) {
            var applicationLink = '/taxi-wat-application?src=myApplicationMenu&appId=' + recId;
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
        else if(isWAT == "true") {
              
            var applicationLink = '/closed-taxi-wat-application?src=myApplicationMenu&appId=' + recId+'&closureStatus=true';
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        } 
        else {
            var applicationLink = '/closed-taxi-application?src=myApplicationMenu&appId=' + recId+'&closureStatus=true';
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
    },
    confirmWithdrawApplicaion : function(component, event, helper){
        
        helper.confirmWithdrawApplicaion(component,event);
    },

    deleteApplication: function(component, event, helper){
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        helper.deleteApplication(component,event, recId);
    }
})