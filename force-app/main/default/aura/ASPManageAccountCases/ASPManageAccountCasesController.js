({
    doInit : function(component, event, helper) {
        console.log('Initializing manage account activity tab');
        helper.showSpinner(component, event);
        helper.getAccount(component, event);        
        $A.util.addClass(component.find('application__item'), 'slds-is-active');
        helper.renderApplicationData(component, event);
         var parameters = decodeURIComponent(window.location.search.substring(1));
        console.log('parameters----->'+parameters);
            var attributes = [];
            var parameter, counter;
            
            parameters = parameters.split("&");
             console.log('parameters----->'+parameters);
        
        
            for(counter = 0; counter < parameters.length; counter++)  {
                
                parameter = parameters[counter].split("=");
                attributes.push({"name": parameter[0], "value": parameter[1]});
                
                console.log('parameter[0]----->'+parameter[0]);
                 console.log('parameter[1]----->'+parameter[1]);
                
                if(parameter[0] == "paymentReference"){
                    console.log('Pr');
                    component.set("v.paymentreferencecheck", parameter[1]);
                }
                
                if(parameter[0] == "status"){
                    console.log('status');
                    component.set("v.statuscheck", parameter[1]);
                }
                  
                
            }
        console.log('sree');
         //helper.updateOrderPaymentMethod(component,event,component.get("v.paymentreferencecheck"));
         console.log('sree6');
        
       console.log(component.get("v.statuscheck"));
        if(component.get("v.statuscheck") === "cancel" ){
            console.log('call method');
           helper.updateOrderPaymentMethod(component,event,component.get("v.paymentreferencecheck"));
            helper.renderApplicationData(component, event);   
        }
       
        
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
    
    closeInternalReviewModal : function(component,event,helper) {
        component.set('v.body',[]);
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
    
    handleCaseNumberOnClick : function(component, event, helper){
        var recordID = event.currentTarget.getAttribute("data-RecId");
        var recordStatus = event.currentTarget.getAttribute("data-Status");
        var recordRecordTypeName = event.currentTarget.getAttribute("data-recordType");               
        var recordPayment = event.currentTarget.getAttribute("data-Payment");
        var recordPaymentStatus = event.currentTarget.getAttribute("data-Payment-Status");
        var recordPaymentMethod = event.currentTarget.getAttribute("data-Payment-Method");
        console.log(recordPaymentMethod);
        var urlStr = null;
        
        console.log(recordRecordTypeName);
        console.log(recordStatus);
        
        if(recordRecordTypeName == 'Reviewable Decisions' && (recordStatus == 'Lodged' || recordStatus == 'Draft' )){
            helper.launchInteralReviewAppForm(component, event, recordID, recordStatus);    
        }else if(recordRecordTypeName == 'Service Provider Administration' && (recordStatus == 'Lodged' || recordStatus == 'Draft' )){
            urlStr="asp-auth-renewal-application?src=myApplicationMenu&appId="+recordID;    
        }else if(recordRecordTypeName == 'Customer Enquiry' && (recordStatus == 'Lodged' || recordStatus == 'Draft' )){
            urlStr="customer-enquiry?src=myApplicationMenu&appId="+recordID;    
        }else if(recordStatus == 'New' || recordStatus == 'Draft' ){
           urlStr="asp-applications?src=myApplicationMenu&appId="+recordID;
        }
        else if(recordPayment != undefined && recordPaymentMethod!=null){
            urlStr="closed-asp-application?src=myApplicationMenu&closureStatus=true&appId="+recordID+"&paymentMethod="+recordPaymentMethod+"&paymentStatus="+recordPaymentStatus+"&isFromManagedAccount=true";      
        } 
        else if(recordPayment != undefined){
            urlStr="closed-asp-application?src=myApplicationMenu&closureStatus=true&appId="+recordID+"&paymentStatus="+recordPaymentStatus+"&isFromManagedAccount=true";      
        }
         else{
            urlStr="closed-asp-application?src=myApplicationMenu&closureStatus=true&appId="+recordID+"&isFromManagedAccount=true";
        }
        
        if(urlStr){
             var navEvt = $A.get("e.force:navigateToURL");
	         navEvt.setParams({
	            "url": urlStr
	         });
	         navEvt.fire();
        }
    }       
})