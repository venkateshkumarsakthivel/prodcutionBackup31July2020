({
    getLegislativeReferences : function(component, event) {
        component.set('v.columns', [
            { label: 'Legislation', fieldName: 'LegislationName', type: 'text', wrapText : true},
            { label: 'Description', fieldName: 'Description', type: 'text', wrapText : true, minColumnWidth:220, initialWidth:450},
            { label: 'Schedule/Section/Clause/Rule', fieldName: 'ScheduleSectionClauseRule', type: 'text',minColumnWidth: 80},
            { label: 'Sub/Section/Clause', fieldName: 'SubSectionClause', type: 'text',minColumnWidth: 80}
        ]);
        
        let caseLegisLoad = component.get('c.getLegislativeReferences');
        caseLegisLoad.setParams({
            "caseId" : component.get('v.caseRecord.Id'),
            "RecordTypeId" : event.getSource().get("v.value")
        });
        
        caseLegisLoad.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let rows = response.getReturnValue();
                for(var i=0; i< rows.length; i++){
                    var row = rows[i];
                    if(row.Legislation__c) {
                        row.LegislationName =  row.Legislation__r.Legislation_Name__c;	
                        row.Description =  row.Legislation__r.Description__c;	
                        row.ScheduleSectionClauseRule = row.Legislation__r.Schedule_Section_Clause_Rule__c;
                        row.SubSectionClause = row.Legislation__r.Sub_Section_Clause__c;
                    }
                }
                component.set("v.data",rows);
                component.set('v.loaded', false);
            }
            else if(state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(caseLegisLoad);
        
    },
    
    fetchListOfRecordTypes: function(component, event) {        
        let action = component.get("c.fetchRecordTypeValues");
        let caseRecord = component.get("v.caseRecord");
        //console.log("caseRecord :"+caseRecord.Record_Type_Dev_Name__c);
        action.setParams({
            "objectName" : "Notice_Record__c",
            "caseType" : caseRecord.Record_Type_Dev_Name__c
        });
        
        action.setCallback(this, function(response) {
            var mapOfRecordTypes = response.getReturnValue();
            //console.log('mapOfRecordTypes:'+JSON.stringify(mapOfRecordTypes));
            var recordTypeList = [];
            for(var key in mapOfRecordTypes){
                recordTypeList.push({Key: key, Value:mapOfRecordTypes[key]});
            }   
            component.set("v.lstOfRecordType", recordTypeList);
            component.set("v.noticeRecordTypeMap",mapOfRecordTypes);
            //console.log("noticeRecordTypeMap:"+JSON.stringify(component.get("v.noticeRecordTypeMap")));
        });
        
        $A.enqueueAction(action);
    },
    
    fetchCaseRelatedRecords: function(component, event) { 
        let getCaseRelatedRec = component.get("c.getCaseRelatedRecords");
        getCaseRelatedRec.setParams({
            "caseId" : component.get('v.caseRecord.Id'),
        });
        getCaseRelatedRec.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                let result = response.getReturnValue();
                //console.log('result: '+JSON.stringify(result));
                component.set("v.caseRelatedRec",result);
            }else if(state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });                
        $A.enqueueAction(getCaseRelatedRec);
    },
    
    createNoticeHandler : function(component, event) {
        /*Carry Case detail to Notice*/
        let caseRec = component.get("v.caseRecord");
        let caseRelatedRec = component.get("v.caseRelatedRec");
        let selectedRows = component.get('v.selectedLegCount');
       
        let AuthorisedOfficerNumber =  component.get("v.AuthorisedOfficerNumber");

        let noticeRec = ({
            'recordTypeId': component.get("v.noticeRecordTypeId"),
            'Case__c': caseRec.Id,
            'Show_On_Industry_Portal__c': 'No',
            'Authorised_Officer_User__c': AuthorisedOfficerNumber,
            'Issued_To__c': caseRec.AccountId,
            'Served_to__c': caseRec.ContactId,
        });
        
        if(typeof (caseRelatedRec.Account) != 'undefined' ){
            let issuetoAddress = (caseRelatedRec.Account.Notice_Address_Street__c + '\n'+caseRelatedRec.Account.Notice_Address_City__c + '\n'+caseRelatedRec.Account.Notice_Address_State__c + '\n'+caseRelatedRec.Account.Notice_Address_Postal_Code__c);
            let methodOfService = caseRelatedRec.Account.Document_Delivery_Preference__c;
            //console.log('issuetoAddress :'+issuetoAddress);
            noticeRec['Issued_to_Address__c'] = issuetoAddress;
            noticeRec['Issued_to_Email__c'] = caseRelatedRec.Account.Notice_Email__c;
            if (methodOfService == "Email") {noticeRec['Method_of_Service__c'] = "Email"; }
        }
        
        if(typeof (caseRelatedRec.Lead_Auditor_User__c) != 'undefined' ){
            //console.log('caseRelatedRec.Lead_Auditor__c:'+caseRelatedRec.Lead_Auditor_User__c)
            noticeRec['Auditor_Email__c'] = caseRelatedRec.Lead_Auditor_User__r.Email;
        }        
        
        /*
        if(){
             noticeRec['Compliance_Date__c'] = $A.localizationService.formatDate(new Date().setDate(14), "YYYY-MM-DD");
        }*/
        
        var createNoticeRecord = component.get("c.createNewNoticeRecord");
        createNoticeRecord.setParams({
            newNotice : JSON.stringify(noticeRec)
        });
        
        createNoticeRecord.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.noticeRecordId",result.Id);
                this.showToastMsg('','Notice Record "'+ result.Name +'" was created.','success');
                
                //Navigate to the Created notice Record 
                /*     var NoticeCreateEvent = $A.get("e.force:navigateToSObject");
                NoticeCreateEvent.setParams({
                    "recordId": result.Id
                });
                NoticeCreateEvent.fire(); */
                if(selectedRows > 0 ){
                    this.createNoticeLegislationRecord(component,event);
                }
                                                
                // Navigate to the next screen in the flow
                var navigate = component.get("v.navigateFlow");
                navigate("NEXT");
                
                //$A.get('e.force:refreshView').fire();
            }else if(state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(createNoticeRecord);
    },
    
    createNoticeLegislationRecord : function(component, event){
        let noticeId = component.get("v.noticeRecordId");
        let selectedLeg = component.get("v.selectedCaseLegislation");        
        //console.log("createNoticeLegislationRecord called");
        
        let action = component.get('c.createNoticeLegislationRecord');
        action.setParams({
            //  "noticeLegislation" : JSON.stringify(noticeLegis)
            "selectedLeg" : JSON.stringify(selectedLeg),
            "noticeId" : noticeId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let rows = response.getReturnValue();
            }
            else if(state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModelHandler: function(component, event){
        component.find('recordTypePickList').set("v.value",null);
        component.set("v.selectedLegCount",0);
        component.set("v.showLegislation",false);
        component.set("v.selectedCaseLegislation",'');
    },
    
    showToastMsg : function(var_title, var_message, var_type){
        //console.log('Event called:'+var_message);
        if(var_title) {var title = var_title;} else {var title = '';}
        if(var_message) {var message = var_message;} else {var message = '';}
        if(var_type) {var toastType = var_type;} else { var toastType = 'other'}
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": toastType,
        });
        toastEvent.fire("Selection Legislation");
    },
    
    getAuthorisedOfficerNumber: function(component, event) {        
        let action = component.get("c.getAuthorisedUser");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var authorisedNumber = response.getReturnValue();
                //console.log('authorisedNumber:'+authorisedNumber);
                component.set("v.AuthorisedOfficerNumber", authorisedNumber);
            }else if(state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('No Authorised Officer Number Present');
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
})