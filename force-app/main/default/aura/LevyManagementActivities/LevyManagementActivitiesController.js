({
    doInit : function(component, event, helper) {
       
        console.log('Initializing manage account activity tab');
        helper.showSpinner(component, event);
        helper.getAccount(component, event);        
        $A.util.addClass(component.find('notice__item'), 'slds-is-active');
        helper.loadData(component, event);
    },
    
    sortNoticeByIssueDate : function(component, event, helper) {
        
        var isCurrentSortOrderAsc = component.get("v.currentNoticeSortOrderASC");
        var notices = component.get("v.noticeList");
            
        if(isCurrentSortOrderAsc) {            
            notices.sort(function(notice1, notice2) {
                var issueDate1 = notice1.Date_Issued__c;
                var issueDate2 = notice2.Date_Issued__c;
                return issueDate1>issueDate2 ? -1 : issueDate1<issueDate2 ? 1 : 0;
            });
            
        } else {            
            notices.sort(function(notice1, notice2) {
                var issueDate1 = notice1.Date_Issued__c;
                var issueDate2 = notice2.Date_Issued__c;
                return issueDate2>issueDate1 ? -1 : issueDate2<issueDate1 ? 1 : 0;
            });
        }
        
        component.set("v.noticeList", notices);
        component.set("v.currentNoticeSortOrderASC", !isCurrentSortOrderAsc);
		helper.renderNoticeData(component, event, notices);
	},
    createCancellationComponent: function(component, event, helper){
        console.log('cancelling application');
        var recId;
        var caseStatus;
        console.log(event.currentTarget);
        if(event.currentTarget == undefined)
            recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-recid");
        else
            recId = event.currentTarget.getAttribute("data-recid");
        console.log(recId);
        if(event.currentTarget == undefined)
            caseStatus = event.getParam('arguments')[1].currentTarget.getAttribute("data-Status");
        else
            caseStatus = event.currentTarget.getAttribute("ddata-Status");
        console.log(caseStatus);
        helper.withdrawApplication(component,helper,recId,caseStatus, 'Cancel');
    },
    createWithdrawnComponent: function(component, event, helper){
        
        var recId;
        var caseStatus;
        if(event.currentTarget == undefined)
            recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-recid");
        else
            recId = event.currentTarget.getAttribute("data-recid");
        
        if(event.currentTarget == undefined)
            caseStatus = event.getParam('arguments')[1].currentTarget.getAttribute("data-Status");
        else
            caseStatus = event.currentTarget.getAttribute("ddata-Status");
        
        helper.withdrawApplication(component,helper,recId,caseStatus, 'Withdraw');
    },
    confirmWithdrawApplicaion : function(component, event, helper){
        helper.confirmWithdrawApplicaion(component,event);
    },
    
    filterShowAllNotices : function(component, event, helper) {        
        helper.showSpinner(component, event);
        $A.util.addClass(component.find('notice__item'), 'slds-is-active');
        $A.util.removeClass(component.find('application__item'), 'slds-is-active');
        component.set('v.isApplicationTab', false);
        helper.loadData(component, event);        
    },
    
    filterApplication : function(component, event, helper) {
        
        component.set('v.isApplicationTab', true);
        
        $A.util.addClass(component.find('application__item'), 'slds-is-active');
        $A.util.removeClass(component.find('notice__item'), 'slds-is-active');
        $A.util.removeClass(component.find('helpRequest__item'), 'slds-is-active');
        
        helper.showSpinner(component, event);
        helper.renderApplicationData(component, event,helper);
    },
    filterHelpRequest : function(component, event, helper) {
        helper.showSpinner(component, event);
        $A.util.addClass(component.find('helpRequest__item'), 'slds-is-active');
        $A.util.removeClass(component.find('notice__item'), 'slds-is-active');
        $A.util.removeClass(component.find('application__item'), 'slds-is-active');
        component.set('v.isApplicationTab', false);
        helper.renderHelpRequestData(component, event,helper);
    },
    
})