({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            { label: 'Legislation', fieldName: 'LegislationName', type: 'text', wrapText : true},
            { label: 'Description', fieldName: 'Description', type: 'text', wrapText : true},
            { label: 'Schedule/Section/Clause/Rule', fieldName: 'ScheduleSectionClauseRule', type: 'text',initialWidth: 80},
            { label: 'Sub/Section/Clause', fieldName: 'SubSectionClause', type: 'text',initialWidth: 80},
            {label: 'Action', type: 'button', initialWidth: 130, minColumnWidth: 120,
             typeAttributes: { label: { fieldName: 'actionLabel'}, title: { fieldName: 'actionTitle'}, name: { fieldName: 'actionName'}, iconName: {fieldName: 'actionIcon'}, disabled: {fieldName: 'actionDisabled'}, class: 'btn_remove'}}
        ]);
        helper.loadLegislation(component,event);
    },    
    
    addLegislationEventHandler : function(component,event,helper){
        helper.addLegislation(component,event);
    },
    
    deleleLegislationHandler: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.loaded", true);
        helper.deleteLegislation(component,event);
    },
    
    onRender : function(component,event,helper){
        helper.invokeExistingLegislationEvt(component,event);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.selectedRow",row);
        let takeAction;
        if(typeof(row.Id) != "undefined"){
            helper.openModel(component);
        } else {
            helper.removeRow(component,event);
        }
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.selectedRow", new Object());
    },
    
    cancelChangesHandler : function(component,event,helper){
        helper.cancelChange(component,event);
    },
    
    saveLegislationHandler : function(component,event,helper){
        //inline edited values in the table are stored in draftValues 
        var draftValues = event.getParam('draftValues');
        component.set("v.loaded", true);
        helper.saveChange(component,draftValues);
    },
    
    onButtonPressed: function(component, event, helper) {
        
        let existingLegislation = component.get("v.existingNoticeLegislation");
        //console.log('existingLegislation length:'+existingLegislation.length);
        let recordtype = component.get("v.recordtype");
        //console.log('recordtype :'+recordtype);
        if ((recordtype == 'Improvement Notice' || recordtype == 'Prohibition Notice') && existingLegislation < 1){
            helper.showToastMsg('',`${recordtype} should have at least one Legislative Reference`,'error'); 
        }
        else {
            // Figure out which action was called
            var actionClicked = event.getSource().getLocalId();
            // Call that action
            var navigate = component.getEvent("navigateFlowEvent");
            navigate.setParam("action", actionClicked);
            navigate.fire();
        }    
    },        
})