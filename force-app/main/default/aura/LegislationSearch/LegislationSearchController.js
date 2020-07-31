({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            { label: 'Add', type: 'button-icon', initialWidth: 80, minColumnWidth: 50 , variant:'Brand' ,
             typeAttributes: { name: 'add_Legislation', title: 'Click to Add Legislation', iconName:"utility:add", disabled: {fieldName: 'actionDisabled'}, class : 'btn_add' }},
            { label: 'Legislation Name', fieldName: 'Legislation_Name__c', type: 'text', wrapText : true, minColumnWidth:200,},
            { label: 'Description', fieldName: 'Description__c', type: 'text', wrapText : true, minColumnWidth:250,},
            { label: 'Schedule/Section/Clause/Rule', fieldName: 'Schedule_Section_Clause_Rule__c', type: 'text',initialWidth: 120, minColumnWidth:100},
             { label: 'Sub/Section/Clause', fieldName: 'Sub_Section_Clause__c', type: 'text',initialWidth: 120, minColumnWidth:100},
        ]);
        
    },
    
    searchRecords : function(component, event, helper) {
        helper.search(component,event);
    }, 
    
    checkString : function(component, event, helper) {
        let searchStr = component.get("v.searchString");
        if(searchStr == ''){
            component.set('v.matchingLegislation',null);
        }
    },
    
    rowSelected : function(component, event, helper){
        let selectedRows = event.getParam('selectedRows');
        component.set('v.addedLegislationCount', selectedRows.length);
    },
    
    handleRowAction : function(component,event,helper){
        helper.invokedLegislation(component,event);
    },
    
    existLegislationEventHandler : function(component,event,helper){
        helper.existLegislation(component,event);
    },
    
    cancelChangesEventHandler : function(component,event,helper){
        helper.cancelChanges(component,event);
    },
            
	removeLegislationEventHandler : function(component,event,helper){
    	helper.removeLegislation(component,event);
    },
})