({
    getAccount : function(component, event) {
        var accountAction = component.get('c.getLoggedInUserAccount');        
        accountAction.setCallback(this, function(result) {
            console.log('getAccount State');
            console.log(result.getState());
            var act = JSON.parse(result.getReturnValue());
            if(act == undefined || act == null){
                act = new Object();
            }
            component.set('v.accountName', act.Name);
            component.set('v.customerNumber', act.Customer_Number__c);
        });
        
        $A.enqueueAction(accountAction);
    },
    updateOrderPaymentMethod : function(component, event, paymentReferenceno) {
    console.log('update order');
       var paymentreference= paymentReferenceno; 
       var getupdateStatus = component.get('c.updateOrderPaymentMethod');
        getupdateStatus.setParams({ "paymentReferenceno" : paymentreference});
       getupdateStatus.setCallback(this, function(response) {
           var state = response.getState();
            
            if(state === "SUCCESS") {
           console.log('updateOrderPaymentMethodsuccess.');
         }	
    
    });
        
        $A.enqueueAction(getupdateStatus);
    
    },
    loadData : function(component, event) {
        console.log('In load Data');
        component.set('v.currentNoticeSortOrderASC', false);
        var action = component.get('c.getNoticeDetails');
        action.setCallback(this,function(result) {
            var state = result.getState();
            console.log(state);
            if(state === "SUCCESS"){
                var response = JSON.parse(result.getReturnValue());
                console.log('before Response');
                console.log(response);
                
                if(response != null) {
                    var noticeMap = {};
                    console.log('before Response');
                    
                    /*
                    for(var i=0;i<response.length;i++)  {                  
                        
                        response[i]["Date_Issued__c"] = this.formatDate(response[i]["Date_Issued__c"]);
                        
                    }
                    */
                    
                    //this.hideSpinner(component, event);
                    component.set('v.noticeList', response);
                    var noticeList = component.get("v.noticeList");
                    console.log('before render data'+response);
                    this.renderNoticeData(component, event, noticeList);
                    
                }
                else {                    
                    component.set('v.noticeList', response);
                    var noticeList = component.get("v.noticeList");
                    this.renderNoticeData(component, event, noticeList);
                    this.hideSpinner(component, event);
                }
            }
            this.hideSpinner(component, event);
        });
        
        $A.enqueueAction(action);       
        
    },
    renderApplicationData : function(component, event) {
        var action = component.get('c.getApplicationCases');
        action.setCallback(this,function(result) {
            var state = result.getState();
            console.log(state);
            if(state === "SUCCESS"){
                var response = JSON.parse(result.getReturnValue());
                console.log('before Response');
                console.log(response);
                
                if(response != null) {
                    console.log('before Response');
                    for(var i=0;i<response.length;i++)  {                  
                        console.log(response[i]["ContactId"]);
                        
                        if(response[i]["Service_Type__c"]  == undefined)
                            response[i]["Service_Type__c"] = '';
                        
                        //response[i]["Date_Submitted__c"] = this.formatDate(response[i]["Date_Submitted__c"]);
                        
                    }
                    component.set('v.casesList', response);
                    var caseList = component.get("v.casesList");
                    this.renderApplicationTable(component, event, caseList, true);
                }
                else {
                    
                    component.set('v.casesList', response);
                    var caseList = component.get("v.casesList");
                    this.renderApplicationTable(component, event, caseList, false);
                    this.hideSpinner(component, event);
                }
            }
            
        });
        
        $A.enqueueAction(action);
    },
    formatDate : function(inputDate) {
        if(inputDate == undefined || inputDate == null){
            return "";
        }
        return (moment(inputDate).format("DD/MM/YYYY"));
    },
    pad: function(inputStr) {        
        return (inputStr < 10) ? '0' + inputStr : inputStr;
    },
    renderApplicationTable : function(component, event, data, renderingApplications) { 
        this.hideSpinner(component, event); 
        return;    
    },
    
    withdrawApplication: function(component,event, recId, caseStatus, confirmType){
        console.log('Present confirmation box for ' + confirmType);
        var message;
        var title;
        if(confirmType == 'Cancel'){
            message = $A.get("$Label.c.ASP_Application_Cancellation_Text");
            title = $A.get("$Label.c.ASP_Application_Cancellation_Title");
        } else {
            message = $A.get("$Label.c.ASP_Withdrawal_Confirmation_Text");
            title = $A.get("$Label.c.ASP_Withdrawal_Confirmation_Title");
        }       
        console.log('Creating confirmation box');
        $A.createComponent(
            "c:WithdrawApplicationConfirmBox",
            {
                "message" : message,
                "confirmType":confirmType,
                "recordId" : recId,
                "title": title,
            },
            function(modalBox, status, errorMessage){
                //Add the new button to the body array
                
                if (status === "SUCCESS") {
                    component.set("v.body", modalBox);
                    this.hideSpinner(component,event);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        ); 
    },
    confirmWithdrawApplicaion :  function(component,event) {        
        this.showSpinner(component, event); 
        var caseRecord = {};
        var recId =  event.getParam("recordId");
        var confirmType = event.getParam("confirmType");
        caseRecord.Id = recId;
        caseRecord.Status = 'Closed';
        var successMsg;
        if(confirmType == 'Cancel'){
            caseRecord.Sub_Status__c = 'Cancelled';
            successMsg = 'Application cancelled successfully.';
        } else {
        	caseRecord.Sub_Status__c = 'Withdrawn';
            successMsg = 'Application withdrawn successfully.';
        }
        var action = component.get('c.withdrawASPApplication');
        action.setParams({
            "caseRec" : caseRecord
        });
        
        action.setCallback(this,function(result){            
            var state = result.getState();            
            if(state == "SUCCESS"){                
                this.hideSpinner(component, event);                 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": successMsg,
                    "duration":10000,
                    "type": "success"
                });
                toastEvent.fire(); 
                
                this.showSpinner(component, event); 
                this.renderApplicationData(component, event);
            } else{
                console.log('Failed to Update application');
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
    },
    
    
    renderNoticeData : function(component, event, data) {
        console.log('rendering notice records');
        var newRecordsToAppend = data;
        console.log(newRecordsToAppend);
        
        $('#noticeTableBody').empty();
        if(newRecordsToAppend == null)
            return;
        
        var tableBodyToAppend = '';
        for(var i=0; i<newRecordsToAppend.length; i++) {
            
            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
            
            rowBody += '<td role="gridcell" class="tabCol" style="width:10%">';
			rowBody += '<div class="slds-truncate slds-text-align--center " id="'+newRecordsToAppend[i].Id+'_Name">';
			rowBody +=  newRecordsToAppend[i].Name + '</div></td>';
			
			rowBody += '<td role="gridcell" class="tabCol" style="width:20%">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_NoticeType">';
            if(newRecordsToAppend[i].Notice_Type__c != undefined){
				rowBody += newRecordsToAppend[i].Notice_Type__c;
			}
			rowBody += '</div></td>';
			
            rowBody += '<td role="gridcell" class="tabCol" style="width:15%">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_ServedTo">';
			if(newRecordsToAppend[i].Served_to__c != undefined){
				rowBody += newRecordsToAppend[i].Served_to__r.Name ;
			}
			rowBody += '</div></td>';
            
			rowBody += '<td role="gridcell"  class="tabCol" style="width:15%">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_MethodOfService">';
			if(newRecordsToAppend[i].Method_of_Service__c != undefined){
				rowBody += newRecordsToAppend[i].Method_of_Service__c;
			}
            rowBody +=  '</div></td>';
			
            rowBody += '<td role="gridcell" class="tabCol" >';
            rowBody += '<div class="slds-truncate slds-text-align--center " id="'+newRecordsToAppend[i].Id+'_DateIssued">';
			if(newRecordsToAppend[i].Date_Issued__c != undefined){
				rowBody += newRecordsToAppend[i].Date_Issued__c ;
			}
			rowBody +=  '</div></td>';
            
			console.log('Row: ' + rowBody);
            tableBodyToAppend += rowBody;            
        }        
        
        $('#noticeTableBody').append(tableBodyToAppend);
        this.hideSpinner(component, event);        
    },
    
    showSpinner : function(component, event){        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component, event){        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    
    launchInteralReviewAppForm : function(component, event, recId, recordStatus){
        //alert('helper'+recId);
        var isReadOnly = false;
        var componentSectionName = "Internal Review Application Detail";
        if(recordStatus == 'Lodged'){
            isReadOnly = true;
            componentSectionName = "Review Details";
        }
        $A.createComponent(
            "c:InternalReviewApplicationForm",
            {
                "record_Id": recId,
                "portalContextName":"ASP",
                "sectionNameToRender": componentSectionName,
                "readOnly":isReadOnly
            },
            function(newComponent, status, errorMessage) {
                //Add the new button to the body array
                if(status === "SUCCESS") {                    
                    component.set("v.body", newComponent);                                       
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }  
            }
        );
    },
    
    
})