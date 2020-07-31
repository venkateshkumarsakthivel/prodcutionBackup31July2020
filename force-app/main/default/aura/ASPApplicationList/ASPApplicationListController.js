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
            "url": "/asp-applications?src=myApplicationMenu"
        });
        urlEvent.fire();   
        helper.hideSpinner(component, event); 
    },
    navigateToApplication : function(component, event, helper){
        
        console.log('navigating to application');
        var recId = event.currentTarget.getAttribute("data-RecId");
        var applicationStatus = event.currentTarget.getAttribute("data-Status");
        var applicationSubStatus = event.currentTarget.getAttribute("data-Substatus");
        var paymentStatus = event.currentTarget.getAttribute("data-PaymentStatus");
        var isClosed = event.currentTarget.getAttribute("data-isClosed");
        console.log('recId ' + recId);
        console.log('Status ' + applicationStatus);
        console.log('Is Closed ' + isClosed);
        var urlEvent = $A.get("e.force:navigateToURL");
        
        if(isClosed == "false" 
            && (applicationStatus == "Draft" || applicationStatus == "New")
            && (applicationSubStatus == null || applicationSubStatus == '' || applicationSubStatus == 'Draft')) {
            
            var applicationLink = '/asp-applications?src=myApplicationMenu&appId=' + recId;
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
        else {
       
            var applicationLink = '/closed-asp-application?src=myApplicationMenu&appId='+recId+'&closureStatus=true&paymentStatus='+paymentStatus;
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