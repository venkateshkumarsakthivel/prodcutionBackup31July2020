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
                    for(var i=0;i<response.length;i++)  {                  
                        
                        response[i]["Date_Issued__c"] = this.formatDate(response[i]["Date_Issued__c"]);
                        
                    }
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
                        
                        response[i]["Date_Submitted__c"] = this.formatDate(response[i]["Date_Submitted__c"]);
                        
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
        
        console.log('In render application records');        
        var newRecordsToAppend = data;
        
        $('#casesTableBody').empty();
        console.log(newRecordsToAppend);
        
        if(newRecordsToAppend == null)
            return;
        
        var tableBodyToAppend = '';
        for(var i=0; i<newRecordsToAppend.length; i++) {
            
            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate slds-text-align--center" id="'+newRecordsToAppend[i].Id+'_CaseNumber">';
            
			if(newRecordsToAppend[i].Status == 'Draft' || newRecordsToAppend[i].Status == 'New') {	
				rowBody += '<a title="Click to resume application"  href="asp-applications?src=myApplicationMenu&appId='+newRecordsToAppend[i].Id+'" target="_blank">'
				rowBody += newRecordsToAppend[i].CaseNumber;  
				rowBody += '</a>';
			} 
            else {		
                
                if(newRecordsToAppend[i].Payment__c != undefined)
				 rowBody += '<a title="Click to review application" href="closed-asp-application?src=myApplicationMenu&closureStatus=true&appId='+newRecordsToAppend[i].Id+'&paymentStatus='+newRecordsToAppend[i].Payment__r.Status+'&isFromManagedAccount=true" target="_blank">'
				else
                 rowBody += '<a title="Click to review application" href="closed-asp-application?src=myApplicationMenu&closureStatus=true&appId='+newRecordsToAppend[i].Id+'&isFromManagedAccount=true" target="_blank">'
                 
                rowBody += newRecordsToAppend[i].CaseNumber;  
				rowBody += '</a>';  
			}
		   
            rowBody += '<div class="slds-truncate slds-text-align--center  toggleDisplay" id="'+newRecordsToAppend[i].Id+'_CaseNumber">';  
            rowBody += '</div></td>';
            
			rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_Record_Type">';
            rowBody += newRecordsToAppend[i].RecordType.Name;
            rowBody += '</div></td>';
            
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_Service_Type">';
            rowBody += newRecordsToAppend[i].Service_Type__c;
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_Status">';
            rowBody += newRecordsToAppend[i].Status;  
            rowBody += '</div></td>';
			
			rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_PaymentStatus">';
			if(newRecordsToAppend[i].Payment__c != undefined){
				rowBody += newRecordsToAppend[i].Payment__r.Status;  
			}            
            rowBody += '</div></td>';
			
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_CreatedByName">';
            rowBody += newRecordsToAppend[i].CreatedBy.Name;
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate slds-text-align--center" id="'+newRecordsToAppend[i].Id+'_DateSubmitted">';
			
			if(newRecordsToAppend[i].Date_Submitted__c != undefined){
				rowBody += newRecordsToAppend[i].Date_Submitted__c;
			}            
            rowBody += '</div></td>';
            
            
            if(newRecordsToAppend[i].Status == 'Lodged'){
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-text-align--center">';
                rowBody += '<a class="withdrawnLink" href="javascript:void(0);" title="Withdraw" target="_blank" data-RecId="'+newRecordsToAppend[i].Id+'" data-Status="'+newRecordsToAppend[i].Status+'">';
                rowBody += 'Withdraw';
                rowBody += '</a> </div>';
                rowBody += '</td></tr>';
            } else if(newRecordsToAppend[i].Status == 'Draft' 
					|| newRecordsToAppend[i].Status == 'New'){
				rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-text-align--center">';
                rowBody += '<a class="cancelLink" href="javascript:void(0);" title="Cancel"  target="_blank" data-RecId="'+newRecordsToAppend[i].Id+'"  data-Status="'+newRecordsToAppend[i].Status+'">';
                rowBody += 'Cancel</a> </div></td></tr>';
			} else {
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-text-align--center">';
                rowBody += '</div></td></tr>';                
            }          
            
			console.log('Row: ' + rowBody);
            tableBodyToAppend += rowBody;            
        }        
        
        $('#casesTableBody').append(tableBodyToAppend);
        $('.withdrawnLink').click(function (ev) { component.withdrawApp(component, ev, this); });
		$('.cancelLink').click(function (ev) { component.cancelApp(component, ev, this); });
        this.hideSpinner(component, event);        
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
				rowBody += newRecordsToAppend[i].Served_to__c ;
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
})