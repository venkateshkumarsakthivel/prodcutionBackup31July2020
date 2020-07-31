({
    doInit : function(component, event, helper) { 
        helper.fetchListOfRecordTypes(component, event);
        helper.fetchCaseRelatedRecords(component, event);
        //console.log("case related rec: "+JSON.stringify(component.get("v.caseRelatedRec")));
        helper.getAuthorisedOfficerNumber(component,event);
    },
    
    onNoticeRecordTypeChange : function(component, event, helper) {
        var selectedCount = component.find('selectedCount');
        $A.util.removeClass(selectedCount, 'selectedCountError');
        let recordTypeId = event.getSource().get("v.value");
        let recordTypeName = event.getSource().get("v.Key");
        //console.log('recordTypeId:'+recordTypeId);
        //console.log('recordTypeName:'+recordTypeName);
        component.set("v.selectedCaseLegislation",new Object());
        component.set("v.selectedLegCount",0);
        component.set("v.data", new Object());
        component.set("v.noticeRecordTypeId", recordTypeId);
        component.set("v.noticeRecordTypeName", recordTypeName);
        if(typeof recordTypeId != 'undefined' && recordTypeId != ""){
            component.set('v.loaded', true);
            helper.getLegislativeReferences(component, event);
            component.set("v.showLegislation",true);
        } else {
            component.set('v.loaded', false);
            component.set("v.showLegislation",false);
        }
    },
    
    updateSelectedLegislation: function (component, event) {
        var selectedCount = component.find('selectedCount');
        $A.util.removeClass(selectedCount, 'selectedCountError');
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedLegCount', selectedRows.length);
        component.set('v.selectedCaseLegislation',selectedRows);
        if(selectedRows.length>0){
            var selectedCount = component.find('selectedCount');
        }        
    },
    
    closeModel: function(component, event, helper) {
        helper.closeModelHandler(component,event);
    },
    
    createNotice: function(component, event, helper){
        var selectedRows = component.get('v.selectedLegCount');
        var noticeRecordTypeMap = component.get("v.noticeRecordTypeMap");
        var selectedNoticeRecordId = component.get("v.noticeRecordTypeId");
        var selectedNoticeRecord = noticeRecordTypeMap[selectedNoticeRecordId];
        //Notice records for Improvement Notice and Prohibition Notice can be created with only 1 LR;
        //Notice records can also be created without any LR
        
        if ((selectedNoticeRecord == 'Improvement Notice' || selectedNoticeRecord == 'Prohibition Notice') && selectedRows > 1 ){
            helper.showToastMsg('',`${selectedNoticeRecord} can have only one Legislative Reference`,'error');            
        } 
        else if((selectedNoticeRecord == 'Improvement Notice' || selectedNoticeRecord == 'Prohibition Notice') && selectedRows < 1 )
        {
            helper.showToastMsg('',`${selectedNoticeRecord} should have at least one Legislative Reference`,'error');            
        }
            else {
                helper.createNoticeHandler(component, event);
            }
    }
})