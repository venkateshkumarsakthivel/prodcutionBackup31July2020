({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            { label: 'Primary', fieldName: 'Primary__c', type: 'boolean', editable:"true", initialWidth: 80},
            { label: 'Legislation', fieldName: 'LegislationName', type: 'text', wrapText : true, initialWidth: 280},
            { label: 'Description', fieldName: 'Description', type: 'text', wrapText : true, minColumnWidth:220 },
            { label: 'Schedule/Section/Clause/Rule', fieldName: 'ScheduleSectionClauseRule', type: 'text',minColumnWidth:80, initialWidth:120},
            { label: 'Sub/Section/Clause', fieldName: 'SubSectionClause', type: 'text',minColumnWidth:80, initialWidth:120},
            //{ label: 'Reason for Change', fieldName: 'Reason_for_Change__c', type: 'text', editable: false},
            //{ label: 'Comment', fieldName: 'Comment__c', type: 'text' , editable:"true" ,wrapText : true},
            {label: 'Action', type: 'button', initialWidth: 150, 
             typeAttributes: { label: { fieldName: 'actionLabel'}, title: { fieldName: 'actionTitle'}, name: { fieldName: 'actionName'}, iconName: {fieldName: 'actionIcon'}, disabled: {fieldName: 'actionDisabled'}, class: 'btn_remove'}},
        ]);
        helper.loadLegislation(component,event);
        helper.loadReasonforChange(component, event);
    },    
    
    addLegislationEventHandler : function(component,event,helper){
        helper.addLegislation(component,event);
    },
    
    updateLegislationHandler: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        helper.updateLegislation(component,event);
    },
    
    onRender : function(component,event,helper){
        helper.invokeExistingLegislationEvt(component,event);
    },
    
    handleRowAction: function (component, event, helper) {
            var action = event.getParam('action');
            var row = event.getParam('row');
            component.set("v.selectedRow",row);
            if(typeof(row.Id) ==="undefined"){
            	helper.removeRow(component,event);
            }else{
                let result=false;
                let action2 = component.get('c.valdiateIfRelatedNoticeSent');
                action2.setParams({
                    "caseLegId" : row.Id
                });
                action2.setCallback(this,function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    result = response.getReturnValue();		
                    //console.log("notice sent result: "+ result +' type of '+ typeof(result));
                    if(typeof(row.Id) != "undefined" && !result){
                        helper.openModel(component);
                    } else if(typeof(row.Id) != "undefined" && result){
                        helper.showToastMsg('Error','Cannot deactivate Legislation as reference attached to active Notices Record','error'); 
                    }else{
                        helper.removeRow(component,event);
                    }
                }else if(state === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            var toast_title = 'Error';
                            var toast_message = errors[0].message;
                            var toast_type = 'error';
                        }
                    } else {
                        console.log("Unknown error");
                        var toast_title = 'Error';
                        var toast_message = 'Unknown error';
                        var toast_type = 'error';
                    }
                }
                });
                $A.enqueueAction(action2);
			}
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.selectedRow", new Object());
        //console.log(JSON.stringify(component.get("v.selectedRow")));
    },
    
    cancelChangesHandler : function(component,event,helper){
        helper.cancelChange(component,event);
    },
    
    saveLegislationHandler : function(component,event,helper){
        //inline edited values in the table are stored in draftValues 
        var draftValues = event.getParam('draftValues');
        helper.saveChange(component,draftValues);
    }
    
})