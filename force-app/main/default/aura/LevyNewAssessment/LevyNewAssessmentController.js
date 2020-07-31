({
    doInit : function(component, event, helper) {   
        
        var recId = component.get("v.recordId");
        console.log('Got Account Id: '+recId);
        component.set("v.accountId", recId);
        helper.validateAssessmentCreation(component, event)
    },
    validateStartDate : function(component, event, helper) {   
        
        console.log('Levy Period Start Date: '+component.get("v.levyStartPeriod"));
        var levyStartDate = component.get("v.levyStartPeriod");
        console.log(levyStartDate);
        
        if(levyStartDate == '')
            return;
        
        helper.showSpinner(component, event);
        
        var levyStartDay = levyStartDate.split("-")[2];
        var levyStartMonth = levyStartDate.split("-")[1];
        var levyStartYear = levyStartDate.split("-")[0];
        
        var dateForLevyStartDate = new Date(levyStartDate);
        console.log('dateForLevyStartDate '+dateForLevyStartDate);
        
        var dateForLevyStartDay = new Date(dateForLevyStartDate.getFullYear(), dateForLevyStartDate.getMonth(), dateForLevyStartDate.getDate());
        console.log('dateForLevyStartDay '+dateForLevyStartDay);
        
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        
        if(component.get("v.rebateApproved")) {
            
            var rebateApprovalDate = component.get("v.rebateApprovalDate");
            console.log('rebateApprovalDate -->'+rebateApprovalDate);
            
            var dateRebateApproval = new Date (rebateApprovalDate);
            var dateForApprovedReabte = new Date(dateRebateApproval.getFullYear(), dateRebateApproval.getMonth() + 1, 0);
            console.log('dateRebateApproval '+dateRebateApproval);
            
            var levyStartDateForApprovedRebate = new Date(dateRebateApproval.getFullYear(), dateRebateApproval.getMonth() + 2, 1);  
            
            if(dateForLevyStartDay > dateRebateApproval)
                levyStartDate = levyStartDateForApprovedRebate.getDate()+'/'+levyStartDateForApprovedRebate.getMonth()+'/'+levyStartDateForApprovedRebate.getFullYear();
            else
                levyStartDate = '01/'+levyStartMonth+'/'+levyStartYear;
            
            console.log('Rebate Approved In: '+rebateApprovalDate);
            console.log('Rebate Approved Levy Start Period: '+levyStartDate);
            component.set("v.levyStartPeriod", levyStartDate);
        }
        else if(component.get("v.exemptionApproved")){
            
            var exemptionApprovalDate = component.get("v.exemptionApprovalDate");
            console.log('exemptionApprovalDate -->'+exemptionApprovalDate);
            
            var exemptionAppDate = new Date(exemptionApprovalDate);
            var dateForApprovedExemption = new Date(exemptionAppDate.getFullYear(), exemptionAppDate.getMonth() + 1, 0);
            console.log('dateForApprovedExemption '+dateForApprovedExemption);
            
            if(dateForLevyStartDay > dateForApprovedExemption){
                
                var returnDate = months[exemptionAppDate.getMonth()]+'/'+exemptionAppDate.getFullYear();
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "You can not create reassessment after exemption approval date. Please select levy start period on or before "+returnDate,
                    "type": "Error",
                    "duration": "10000"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                
                levyStartDate = '01/'+levyStartMonth+'/'+levyStartYear;
                console.log('Exemption Approved In: '+exemptionApprovalDate);
                console.log('Exemption is Approved but eligible for Previous Assessment: '+levyStartDate);
                component.set("v.levyStartPeriod", levyStartDate);
            }
        }
            else {
                
                levyStartDate = '01/'+levyStartMonth+'/'+levyStartYear;
                console.log('Rebate/Exemption Not Approved: '+levyStartDate);
                component.set("v.levyStartPeriod", levyStartDate);
            }
        
        var endDateAction = component.get("c.retrieveLevyEndDate");
        endDateAction.setParams({
            "levyStartDate": levyStartDate,
            "activeTPR": component.get("v.registrationRecord")
        });
        endDateAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                component.set("v.levyEndPeriod", response.getReturnValue());
            }
        });
        endDateAction.setBackground();
        $A.enqueueAction(endDateAction);
        
        helper.fetchMatchingAssessments(component, event, levyStartDate);
    },
    createCase : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event) == false) {  
            
            document.querySelector("#generalErrorMsgDiv").style.display = 'none';
            helper.createAssessmentCase(component, event);
        }
        else {
            
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#generalErrorMsgDiv").scrollIntoView();
            return;
        }
    },
    cancelAssessmentCreation : function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
    }
})