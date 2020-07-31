({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            { label: 'Add', type: 'button-icon', initialWidth: 50, variant:'Brand' ,
             typeAttributes: { name: 'add_Legislation', title: 'Click to Add Legislation', iconName:"utility:add", disabled: {fieldName: 'actionDisabled'}, class : 'btn_add' }},
            { label: 'Legislation Name', fieldName: 'LegislationName', type: 'text', wrapText : true, minColumnWidth:200,initialWidth:250},
            { label: 'Description', fieldName: 'Description', type: 'text', wrapText : true, minColumnWidth:200},
            { label: 'Schedule/Section/Clause/Rule', fieldName: 'ScheduleSectionClauseRule', type: 'text', minColumnWidth:80, initialWidth:90},
            { label: 'Sub/Section/Clause', fieldName: 'SubSectionClause', type: 'text',minColumnWidth:80, initialWidth:85},
        ]);
            helper.loadCaseLeg(component,event);
            //helper.search(component,event); 
    },
    
    rowSelected : function(component, event, helper){
        let selectedRows = event.getParam('selectedRows');
    },
    
    handleRowAction : function(component,event,helper){
        let existingLegislation = component.get("v.existingLegislation");
        let selectedNoticeRecord = component.get("v.recordtype");
        let existingLegislationcount = existingLegislation.length;
        //console.log('existingLegislationcount:'+existingLegislationcount); 
        let addLeg = component.get('v.addedLegislation');
        //console.log('addLeg: '+JSON.stringify(addLeg));
            
        if ((selectedNoticeRecord == 'Improvement Notice' || selectedNoticeRecord == 'Prohibition Notice') && existingLegislationcount >= 1 ){
            helper.showToastMsg('',`${selectedNoticeRecord} can have only one Legislative Reference`,'error');
        } else {
            helper.invokedLegislation(component,event);
        }
    },
    
    existLegislationEventHandler : function(component,event,helper){
       //console.log('existLegislationEventHandler');
       helper.existLegislation(component,event);
    },
    
    cancelChangesEventHandler : function(component,event,helper){
        helper.cancelChanges(component,event);
    },
            
   saveChangesEventHandler : function(component,event,helper){
   	helper.saveChanges(component,event);
   },
            
	removeLegislationEventHandler : function(component,event,helper){
    	helper.removeLegislation(component,event);
    },
})