({
    setNoticeRecordDetails : function(component, event) {
    },
    
    noticeSubTypeChangeHandler : function(component, event) {
        var noticeType = component.find("noticeType").get("v.value");
        var noticeSubType = component.find("noticeSubType").get("v.value");
        var fieldSetKey = noticeType + '_' + noticeSubType; 
        console.log('fieldSetKey:'+fieldSetKey);
        component.set("v.noticeSubTypeVal",noticeSubType);
        component.set("v.showSpinner",true);
        //console.log('component.get("v.noticeSetting"):'+JSON.stringify(component.get("v.noticeSetting")));
        let fieldSet = component.get("v.noticeSetting")[fieldSetKey];
        //console.log('field Set : '+fieldSet);
        component.set('v.fieldSetName',fieldSet);
        this.loadFieldSet(component,event);
    },
    
    submitHandler : function(component, event){
        let noticeRecord = component.get("v.noticeRecord");
        var NoticeCreateEvent = $A.get("e.force:navigateToSObject");
        NoticeCreateEvent.setParams({
            "recordId": noticeRecord.Id
        });
        this.showToastMsg('','Notice Record "'+ noticeRecord.Name +'" was Updated.','success');
        NoticeCreateEvent.fire();
    },
    
    cancelHandler : function(component, event){
        let noticeRecord = component.get("v.noticeRecord");
        var NoticeCreateEvent = $A.get("e.force:navigateToSObject");
        NoticeCreateEvent.setParams({
            "recordId": noticeRecord.Id
        });
        this.showToastMsg('','Changes to Record "'+ noticeRecord.Name +'" are Not Saved.','info');
        NoticeCreateEvent.fire();
    },
    
    loadFieldSet : function(component, event){
        component.set("v.showSpinner",true);
        //console.log('FieldSetFormController.init');
        var fieldSetName = component.get('v.fieldSetName');
        var sobjectName = component.get('v.sObjectName');
        var recordId = component.get('v.recordId');
        if (!fieldSetName) {
            //console.log('The field set is required.');
            component.set("v.showSpinner",false);
            component.set("v.showFieldset",false);
            return;
        }        
        var getFormAction = component.get('c.getForm');
        getFormAction.setParams({
            fieldSetName: fieldSetName,
            objectName: sobjectName,
            recordId: recordId
        });        
        getFormAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var form = response.getReturnValue();
                component.set('v.fields', form.Fields);
                component.set("v.showFieldset",true);
                component.set("v.showSpinner",false);
                //component.set("v.showBtns",true);
            } else if(state === "ERROR") {
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
        $A.enqueueAction(getFormAction);
    },
    
    loadNoticeMetadataSetting : function(component, event){
        let noticeSetting = component.get("c.getNoticeMataDataSetting");
        noticeSetting.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let metadataMap = response.getReturnValue();	
                component.set("v.noticeSetting",metadataMap);
                this.loadNoticeRecord(component,event);
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
        $A.enqueueAction(noticeSetting);
    },
    
    loadNoticeRecord :function(component, event){
        //console.log('Load Notice Record Controller');
        let recordId = component.get("v.recordId");        
        let noticeRec = component.get('c.getNoticeRecord');
        noticeRec.setParams({
            noticeId : recordId
        });       
        noticeRec.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                //console.log('loadNoticeRecord called');
                let noticeRecord = response.getReturnValue();
               // console.log('noticeRecord :'+JSON.stringify(noticeRecord));
                component.set("v.noticeRecord",noticeRecord);
                component.set("v.noticeName",noticeRecord.Name);
                if(typeof(noticeRecord.Notice_Type__c) != 'undefined'){
                    console.log('noticeRecord.Notice_Type__c:'+noticeRecord.Notice_Type__c);
                    component.set("v.noticeTypeVal",noticeRecord.Notice_Type__c);
                }
                if(typeof(noticeRecord.Notice_Sub_Type__c) != 'undefined'){
                  //  console.log('noticeRecord.Notice_Sub_Type__c:'+noticeRecord.Notice_Sub_Type__c);
                    component.set("v.noticeSubTypeVal",noticeRecord.Notice_Sub_Type__c);
                }
                //Showing Save button when displayed in Case flow or when Status is Draft
                let showTypeSubType = component.get("v.showTypeSubType");
                if(showTypeSubType == true || noticeRecord.Status__c == 'Draft'){
                    //show 
                    component.set("v.showBtns",true);
                } else {
                    //Hide Save button when Status is other than Draft
                    component.set("v.showBtns",false);
                }
                
                let noticeType = component.get("v.noticeTypeVal");
                let noticeSubType = component.get("v.noticeSubTypeVal");
                let fieldSetKey = noticeType + '_' + noticeSubType; 
                                
                if(noticeSubType == ''){
                    component.set('v.showFieldset',false);
                } else {
                    let fieldSet = component.get("v.noticeSetting")[fieldSetKey];
                    if (fieldSet != ''){
                        if(fieldSet == '' || typeof(fieldSet) == 'undefined'){
                            component.set('v.showFieldset',false);
                            //hiding button from detail page as not fields set found
                            if(showTypeSubType == false){
                                component.set("v.showBtns",false);
                            }
                        } else{
                            component.set('v.showFieldset',false);
                            component.set('v.fieldSetName',fieldSet);
                            this.loadFieldSet(component,event);
                        }
                    }
                }
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
        $A.enqueueAction(noticeRec);
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
})