({
    doInit : function(component, event, helper) {
        //console.log('doInit recordId:',component.get('v.recordId'));
        let showTypeSubType = component.get("v.showTypeSubType");
        
        let noticeRec = component.get('c.getNoticeRecord');
        noticeRec.setParams({
            noticeId : component.get('v.recordId')
        });       
        noticeRec.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let noticeRecord = response.getReturnValue();
                component.set("v.noticeRecord",noticeRecord);
                component.set("v.noticeName",noticeRecord.Name);
                helper.loadNoticeMetadataSetting(component,event);
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
    
    onEditFormLoad : function(component, event, helper) { 
        //helper.loadFieldSet(component, event);
    },
    
    onNoticeTypeChange : function(component, event, helper){
        component.find("noticeSubType").set("v.value",'');
        component.set('v.showFieldset',false);
    },
    
    onNoticeSubTypeChange : function(component, event, helper){
        var noticeType = component.find("noticeType").get("v.value");
        var noticeSubType = component.find("noticeSubType").get("v.value");
        //console.log('noticeSubType :'+noticeSubType);
        if(noticeSubType == '' || noticeType == ''){
            component.set('v.showFieldset',false);
        } else {
            component.set('v.showFieldset',true);
            helper.noticeSubTypeChangeHandler(component, event);
        }
    },
    
    onEditFormSubmit : function(component, event, helper) {
        //console.log("submit");
        helper.submitHandler(component, event);
    },
    
    onEditFormCancel :function(component, event, helper) {
        //console.log("cancel");
        helper.cancelHandler(component, event);
    },
})