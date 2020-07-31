({
    getAccount : function(component, event) {
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        if(accountId == '') {
            
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
        }
        else {
            
            var accountAction = component.get('c.getAccountDataForAgents');  
            accountAction.setParams({
                "accId": accountId
            });
            accountAction.setCallback(this, function(result) {
                
                var res = result.getReturnValue();
                
                if(res == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                else {
                    
                    var act = JSON.parse(res);
                    component.set('v.accountName', act.Name);
                    component.set('v.customerNumber', act.Customer_Number__c);
                }
            });
            $A.enqueueAction(accountAction); 
        }
    },
    loadData : function(component, event) {
        
        console.log('In load Data');
        var accountId = component.get("v.accountId");
        
        component.set('v.currentNoticeSortOrderASC', false);
        var action = component.get('c.getNoticeDetails');
        action.setParams({
            "requiredAccId": accountId
        });
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
        
        var accountId = component.get("v.accountId");
        
        if(accountId == '') {
            
            var action = component.get('c.getApplicationCases');
            action.setCallback(this,function(result) {
                
                var state = result.getState();
                console.log(state);
                
                if(state === "SUCCESS") {
                    
                    var response = JSON.parse(result.getReturnValue());
                    console.log('before Response');
                    console.log(response);
                    
                    if(response != null) {
                        console.log('before Response');
                        for(var i=0;i<response.length;i++)  {                  
                            console.log(response[i]["ContactId"]);
                            console.log(response[i]["Service_Type__c"]);
                            
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
                    }
                    
                    this.hideSpinner(component, event);
                }            
            });
            
            $A.enqueueAction(action);
        }
        else {
            
            var action = component.get('c.getApplicationCasesForAgent');
            action.setParams({
                "requiredAccId": accountId
            });
            action.setCallback(this,function(result) {
                var state = result.getState();
                console.log(state);
                if(state === "SUCCESS") {
                    
                    var actionResponse = result.getReturnValue();
                    
                    if(actionResponse == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                        
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Error",
                            "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                            "type": "error",
                            "duration":10000
                        });
                        toastEvent.fire();
                    }
                    else {
                        
                        var response = JSON.parse(actionResponse);
                        console.log('before Response');
                        console.log(response);
                        
                        if(response != null) {
                            console.log('before Response');
                            for(var i=0;i<response.length;i++)  {                  
                                console.log(response[i]["ContactId"]);
                                console.log(response[i]["Service_Type__c"]);
                                
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
                        }
                    }
                    this.hideSpinner(component, event);
                }
                
            });
            
            $A.enqueueAction(action);
        }
    },
    formatDate : function(inputDate) {
        if(inputDate == undefined || inputDate == null){
            return "";
        }
        //return (moment(inputDate).format("DD/MM/YYYY"));
		return "18/10/2018";        
    },
    pad: function(inputStr) {        
        return (inputStr < 10) ? '0' + inputStr : inputStr;
    },
    renderApplicationTable : function(component, event, data, renderingApplications) {
        
        this.hideSpinner(component, event);
        return;
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
            
            if(newRecordsToAppend[i].Sub_Type__c == 'Renewal Application') {
                
                rowBody += '<a title="Click to resume application" href="taxi-resume-renewal-application?src=myApplicationMenu&appId='+newRecordsToAppend[i].Id+'&appSubStatus='+newRecordsToAppend[i].Sub_Status__c+'" target="_blank">';
                rowBody += newRecordsToAppend[i].CaseNumber;  
                rowBody += '</a>';
            }
            else if(newRecordsToAppend[i].Sub_Type__c == 'Transfer - Owner') {
                
                rowBody += '<a title="Click to resume application" href="taxi-transfer?appId='+newRecordsToAppend[i].Id+'&appSubStatus='+newRecordsToAppend[i].Sub_Status__c+'" target="_blank">';
                rowBody += newRecordsToAppend[i].CaseNumber;  
                rowBody += '</a>';
            }
                else if(newRecordsToAppend[i].Sub_Type__c == 'Surrender') {
                    
                    //rowBody += '<a title="Click to resume application" href="taxi-transfer?appId='+newRecordsToAppend[i].Id+'&appSubStatus='+newRecordsToAppend[i].Sub_Status__c+'" target="_blank">';
                    rowBody += newRecordsToAppend[i].CaseNumber;  
                    rowBody += '</a>';
                }
                    else if(newRecordsToAppend[i].Sub_Type__c == 'Awaiting Plates') {
                        
                        //rowBody += '<a title="Click to resume application" href="taxi-transfer?appId='+newRecordsToAppend[i].Id+'&appSubStatus='+newRecordsToAppend[i].Sub_Status__c+'" target="_blank">';
                        rowBody += newRecordsToAppend[i].CaseNumber;  
                        rowBody += '</a>';
                    }
                        else if(newRecordsToAppend[i].Sub_Type__c == 'Transfer - Proposed Owner') {
                            
                            rowBody += '<a title="Click to resume application" href="transfer-party-b?appId='+newRecordsToAppend[i].Id+'&appSubStatus='+newRecordsToAppend[i].Sub_Status__c+'" target="_blank">';
                            rowBody += newRecordsToAppend[i].CaseNumber;  
                            rowBody += '</a>';
                        }
                            else if(newRecordsToAppend[i].Sub_Type__c == 'Internal review'){
                                // for internal review applications
                                rowBody += '<a title="Click to view application" href="transfer-party-b?appId='+newRecordsToAppend[i].Id+'&appSubStatus='+newRecordsToAppend[i].Sub_Status__c+'" target="_blank">';
                                rowBody += newRecordsToAppend[i].CaseNumber;  
                                rowBody += '</a>';
                            }
                                else if(newRecordsToAppend[i].Is_WAT_Application__c == false && (newRecordsToAppend[i].Status == 'Draft' || newRecordsToAppend[i].Status == 'New')) {
                                    
                                    rowBody += '<a title="Click to resume application"  href="taxi-applications?src=myApplicationMenu&appId='+newRecordsToAppend[i].Id+'" target="_blank">'
                                    rowBody += newRecordsToAppend[i].CaseNumber;  
                                    rowBody += '</a>';
                                }
                                    else if(newRecordsToAppend[i].Is_WAT_Application__c == true && (newRecordsToAppend[i].Status == 'Draft' || newRecordsToAppend[i].Status == 'New')) {
                                        
                                        rowBody += '<a title="Click to resume application" href="taxi-wat-application?src=myApplicationMenu&appId='+newRecordsToAppend[i].Id+'" target="_blank">'
                                        rowBody += newRecordsToAppend[i].CaseNumber;  
                                        rowBody += '</a>';
                                    }
                                        else if(newRecordsToAppend[i].Is_WAT_Application__c == true) {
                                            
                                            rowBody += '<a title="Click to view application" href="closed-taxi-wat-application?src=myApplicationMenu&appId='+newRecordsToAppend[i].Id+'&closureStatus=true" target="_blank">'
                                            rowBody += newRecordsToAppend[i].CaseNumber;  
                                            rowBody += '</a>';
                                        }
                                            else {		
                                                
                                                if(newRecordsToAppend[i].Orders__r != undefined && newRecordsToAppend[i].Orders__r != null && newRecordsToAppend[i].Orders__r.totalSize > 0)
                                                    rowBody += '<a title="Click to review application" href="closed-taxi-application?src=myApplicationMenu&closureStatus=true&appId='+newRecordsToAppend[i].Id+'&paymentStatus='+newRecordsToAppend[i].Orders__r.records[0].Status+'&isFromManagedAccount=true" target="_blank">'
                                                    else
                                                        rowBody += '<a title="Click to review application" href="closed-taxi-application?src=myApplicationMenu&closureStatus=true&appId='+newRecordsToAppend[i].Id+'&isFromManagedAccount=true" target="_blank">'
                                                        
                                                        rowBody += newRecordsToAppend[i].CaseNumber;  
                                                rowBody += '</a>';  
                                            }
            
            rowBody += '<div class="slds-truncate slds-text-align--center  toggleDisplay" id="'+newRecordsToAppend[i].Id+'_CaseNumber">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_Record_Type">';
            rowBody += newRecordsToAppend[i].Sub_Type__c;
            rowBody += '</div></td>';
            
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_Status">';
            rowBody += newRecordsToAppend[i].Status;  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate" id="'+newRecordsToAppend[i].Id+'_PaymentStatus">';
            if(newRecordsToAppend[i].Orders__r != undefined && newRecordsToAppend[i].Orders__r != null && newRecordsToAppend[i].Orders__r.totalSize > 0){
                rowBody += newRecordsToAppend[i].Orders__r.records[0].Status;    
            }            
            rowBody += '</div></td>';
            
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate slds-text-align--center" id="'+newRecordsToAppend[i].Id+'_DateSubmitted">';
            
            if(newRecordsToAppend[i].Date_Submitted__c != undefined){
                rowBody += newRecordsToAppend[i].Date_Submitted__c;
            }
            
            if((newRecordsToAppend[i].Date_Submitted__c == "") && (newRecordsToAppend[i].Sub_Type__c == 'Surrender')){
                var getCreatedDate = newRecordsToAppend[i].CreatedDate;
                var getDate = getCreatedDate.substring(0, 10);
                var dateArray = getDate.split("-");
                rowBody += dateArray[2]+'/'+dateArray[1]+'/'+dateArray[0];
            }
            
            if((newRecordsToAppend[i].Date_Submitted__c == "") && (newRecordsToAppend[i].Sub_Type__c == 'Awaiting Plates')){
                var getCreatedDate = newRecordsToAppend[i].CreatedDate;
                var getDate = getCreatedDate.substring(0, 10);
                var dateArray = getDate.split("-");
                rowBody += dateArray[2]+'/'+dateArray[1]+'/'+dateArray[0];
            }
            
            if((newRecordsToAppend[i].Status == 'Draft' 
                || newRecordsToAppend[i].Status == 'New') && 
               (newRecordsToAppend[i].Sub_Type__c == 'Renewal Application'
                || ((newRecordsToAppend[i].Is_WAT_Application__c == true) && (newRecordsToAppend[i].Status == 'Draft' || newRecordsToAppend[i].Status == 'New'))
                || ((newRecordsToAppend[i].Sub_Type__c == 'Internal review') && (newRecordsToAppend[i].Status == 'Draft' || newRecordsToAppend[i].Status == 'New'))
                || newRecordsToAppend[i].Sub_Type__c == 'New Application' )){
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-text-align--center">';
                rowBody += '<a class="cancelLink" href="javascript:void(0);" title="Cancel"  target="_blank" data-RecId="'+newRecordsToAppend[i].Id+'"  data-Status="'+newRecordsToAppend[i].Status+'" data-Sub_Type__c="'+newRecordsToAppend[i].Sub_Type__c+'" data-authId="'+newRecordsToAppend[i].Authorisation__c+'">';
                rowBody += 'Cancel</a> </div></td></tr>';
            }else {
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-text-align--center">';
                if(newRecordsToAppend[i].Sub_Type__c == 'Internal review')
                   rowBody += '<a class="cancelLink" href="javascript:void(0);" title="Withdraw"  target="_blank" data-RecId="'+newRecordsToAppend[i].Id+'"  data-Status="'+newRecordsToAppend[i].Status+'" data-Sub_Type__c="'+newRecordsToAppend[i].Sub_Type__c+'" data-authId="'+newRecordsToAppend[i].Authorisation__c+'">';
                rowBody += '</div></td></tr>';                
            }        
            rowBody += '</div></td>';
            
            console.log('Row: ' + rowBody);
            tableBodyToAppend += rowBody;            
        }        
        
        $('#casesTableBody').append(tableBodyToAppend);
        $('.cancelLink').click(function (ev) { component.cancelApp(component, ev, this); });
        this.hideSpinner(component, event);        
    },
    cancelOrWithdrawApplication: function(component,event, recId, caseStatus, confirmType, subType){
        console.log('Present confirmation box for ' + confirmType);
        var message;
        var title;
        
        if(confirmType == 'Cancel'){
            message = $A.get("$Label.c.ASP_Application_Cancellation_Text");
            title = $A.get("$Label.c.ASP_Application_Cancellation_Title");
        } else {																//withdraw
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
                "subType": subType
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
    confirmCancelOrWithdrawApplication :  function(component,event) {    
        console.log('in helper handler');
        this.showSpinner(component, event); 
        var caseRecord = {};
        var recId =  event.getParam("recordId");
        var subType = event.getParam("subType");
        console.log('subTypesubType: '+subType);
        var confirmType = event.getParam("confirmType");
        caseRecord.Id = recId;
        caseRecord.Status = 'Closed';
        caseRecord.Sub_Type__c = subType;
        var successMsg;
        if(confirmType == 'Cancel'){
            caseRecord.Sub_Status__c = 'Cancelled';
            successMsg = 'Application cancelled successfully.';
        } else {
        	caseRecord.Sub_Status__c = 'Withdrawn';
            successMsg = 'Application withdrawn successfully.';
        }
        var action = component.get('c.cancelTaxiApplication');
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
    handleCaseNumClick : function(component, event){
        var recordID = event.currentTarget.getAttribute("data-RecId");
        var recordStatus = event.currentTarget.getAttribute("data-Status");
        var recordRecordTypeName = event.currentTarget.getAttribute("data-recordType");               
        var recordOrders = event.currentTarget.getAttribute("data-Orders");
        var recordSubStatus = event.currentTarget.getAttribute("data-Sub-Status");
        var recordSubType = event.currentTarget.getAttribute("data-Sub-Type");
        var recordIsWatApp = event.currentTarget.getAttribute("data-Is_WatApp") == "true" ? true : false;
        var urlStr = null;
        
        if(recordRecordTypeName == 'Reviewable Decisions' && (recordStatus == 'Lodged' || recordStatus == 'Draft' )){
            this.launchInteralReviewAppForm(component, event, recordID, recordStatus);
        }else if(recordSubType == 'Renewal Application'){
            urlStr = "taxi-resume-renewal-application?src=myApplicationMenu&appId="+recordID+"&appSubStatus="+recordSubStatus;
        }else if(recordSubType == 'Transfer - Owner'){
            urlStr = "taxi-transfer?appId="+recordID+"&appSubStatus="+recordSubStatus;
        }else if(recordSubType == 'Transfer - Proposed Owner'){
            urlStr = "transfer-party-b?appId="+recordID+"&appSubStatus="+recordSubStatus;
        }else if(recordSubType == 'Internal review'){
            urlStr="transfer-party-b?appId="+recordID+"&appSubStatus="+recordSubStatus;
        }else if(recordIsWatApp == false && (recordStatus == 'Draft' || recordStatus == 'New')){
            urlStr="taxi-applications?src=myApplicationMenu&appId="+recordID;
        }else if(recordIsWatApp == true && (recordStatus == 'Draft' || recordStatus == 'New')){
            urlStr="taxi-wat-application?src=myApplicationMenu&appId="+recordID;
        }else if(recordIsWatApp == true){
            urlStr="closed-taxi-wat-application?src=myApplicationMenu&appId="+recordID+"&closureStatus=true";
        }else if(recordOrders && recordOrders.totalSize > 0){
            urlStr = "closed-taxi-application?src=myApplicationMenu&closureStatus=true&appId="+recordID+"&paymentStatus="+recordOrders[0].Status+"&isFromManagedAccount=true";
        }else{
            urlStr = "closed-taxi-application?src=myApplicationMenu&closureStatus=true&appId="+recordID+"&isFromManagedAccount=true";
        }
        
        if(urlStr){
            var navEvt = $A.get("e.force:navigateToURL");
            navEvt.setParams({
                "url": urlStr
            });
            navEvt.fire();
        }
    },
    launchInteralReviewAppForm : function(component, event, recId, recordStatus){
        
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