({ 
    loadCaseLeg : function(component,event){
        //console.log('loadCaseLeg');
        let caseId = component.get("v.caseId");
        let action = component.get("c.loadCaseLegislation");
        let noticeId = component.get("v.recordId");
        //console.log('caseId: '+caseId);
        //console.log('noticeId: '+noticeId);
        component.set("v.loaded", true);
        action.setParams({
            "caseId" : caseId,
            "noticeId" : noticeId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let responseValue = response.getReturnValue();
                component.set("v.caseLegislation",responseValue);
                //console.log('caseLegislation:'+JSON.stringify(component.get("v.caseLegislation")));
                component.set("v.loaded", false);
                this.search(component, event);
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
    
    search : function(component, event) {
        //console.log('search');
        let valLeg = [];
        let caseLegislation = component.get("v.caseLegislation");
        let existingLegis = component.get("v.existingLegislation");
        //console.log('existingLegis:'+JSON.stringify(existingLegis));
        const existingLegisMap = new Map(existingLegis.map(obj =>[obj.Id,obj]));
        
        let addedLegis = component.get("v.addedLegislation");
        const addedLegisMap = new Map(addedLegis.map(obj =>[obj.Legislation__c,obj]));
        //console.log('addedLegis:'+JSON.stringify(addedLegis));
        
        caseLegislation.map(function(resRow) {
            if(addedLegisMap.has(resRow.Legislation__c)||existingLegisMap.has(resRow.Legislation__c)){
                // console.log('Legislation Present: '+resRow.Legislation__c);
            } else {
                //adding to new List if not in the existing or added Legislation 
                if(resRow.Legislation__c) {
                    resRow.LegislationName =  resRow.Legislation__r.Legislation_Name__c;	
                    resRow.Description =  resRow.Legislation__r.Description__c;	
                    resRow.ScheduleSectionClauseRule = resRow.Legislation__r.Schedule_Section_Clause_Rule__c;
                    resRow.SubSectionClause = resRow.Legislation__r.Sub_Section_Clause__c;
                }
                valLeg.push(resRow);
            } 
        });        
        
        component.set("v.matchingLegislation",valLeg);
        //console.log('matchingLegislation:'+JSON.stringify(component.get("v.matchingLegislation"))); 
    },
    
    invokedLegislation : function(component,event){
        var row = event.getParam('row');
        let newLegAdded = JSON.parse(JSON.stringify(row));
        //console.log('invokedLegislation newLegAdded:'+JSON.stringify(newLegAdded));
        
        let addLeg = component.get('v.addedLegislation');
        //console.log('addLeg: '+JSON.stringify(addLeg));
        addLeg.push(newLegAdded);
        
        let selectedNoticeRecord = component.get("v.recordtype");
        
       if ((selectedNoticeRecord == 'Improvement Notice' || selectedNoticeRecord == 'Prohibition Notice') && addLeg.length > 1 ){
           addLeg.pop(newLegAdded);
            this.showToastMsg('',`${selectedNoticeRecord} can have only one Legislative Reference`,'error');
        } else { 
            let addLeg2 = component.get('v.addedLegislation');
            //console.log('addLeg2: '+JSON.stringify(addLeg2));
            component.set('v.addedLegislation',addLeg2);
            var data = component.get('v.matchingLegislation');
            var validLeg = []
            data = data.map(function(rowData) {
                if (rowData.Legislation__c!== row.Legislation__c) {
                    validLeg.push(rowData);
                }
            });
            //console.log('validLeg:'+JSON.stringify(validLeg));
            component.set("v.matchingLegislation", validLeg);
            
            var addLegEvent = $A.get("e.c:AddLegislationEvent");
            //console.log('addLegEvent:'+addLegEvent);
            addLegEvent.setParams({"selectedLegislation":row});
            //console.log('addLegEvent fired');
            addLegEvent.fire();
        }
    },
    
    removeLegislation : function(component,event){
        
        let removeLegis = event.getParam("removedLegislation");
        
        let addedLeg = component.get("v.addedLegislation");
        var addedLegMap = new Map(addedLeg.map(i => [i.Legislation__c, i]));
        
        if(addedLegMap.has(removeLegis)){
            addedLegMap.delete(removeLegis);
        } 
        
        let finalAddedLeg = new Array();
        addedLegMap.forEach(function(dval,index){
            finalAddedLeg.push(dval);
        });
        
        component.set("v.addedLegislation",finalAddedLeg);
        this.search(component, event);
    },
    
    existLegislation : function(component,event){
        //console.log('existLegislation');
        let exLegis = event.getParam("existLegislations");
        component.set("v.existingLegislation",exLegis);
        this.loadCaseLeg(component, event);
        //this.search(component, event);
    },
    
    cancelChanges : function(component,event){
        component.set("v.addedLegislationCount",0);
        component.set("v.addedLegislation",new Array());
        this.search(component, event);
    },
    
    saveChanges : function(component,event){
        component.set("v.addedLegislation",new Array());
        this.loadCaseLeg(component, event);
        //this.search(component, event);
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
        toastEvent.fire();
    }
    
});