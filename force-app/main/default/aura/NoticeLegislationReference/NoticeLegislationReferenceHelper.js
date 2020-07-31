({    
    //Load Case Legislation based on the Case Id and show in the table
    loadLegislation  : function(component,event) {
        //console.log('loadLegislation');
        let noticeId = component.get('v.noticeId');
        let action = component.get('c.loadNoticeLegislation');
        component.set("v.loaded", true);
        action.setParams({
            "noticeId" : noticeId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let rows = response.getReturnValue();
                for(var i=0; i< rows.length; i++){
                    var row = rows[i];
                    //console.log('row: '+JSON.stringify(row));
                    if(row.Legislation__c) {
                        row.LegislationName =  row.Legislation__r.Legislation_Name__c;	
                        row.Description =  row.Legislation__r.Description__c;	
                        row.ScheduleSectionClauseRule = row.Legislation__r.Schedule_Section_Clause_Rule__c;
                        row.SubSectionClause = row.Legislation__r.Sub_Section_Clause__c;
                        row.Legislation__c = row.Legislation__c;
                    }if(row.Id){
                        row.actionLabel = 'Delete';
                        row.actionTitle = 'Click to Delete';
                        row.actionIcon='utility:delete';
                        row.actionName = 'Delete';
                    } else{
                        //console.log('No Row');
                    }
                }
                component.set("v.existingNoticeLegislation",rows);
                //console.log("existingCaseLegislature"+JSON.stringify(component.get("v.existingCaseLegislature")));
                component.set("v.data",rows);
                //console.log("draftData"+JSON.stringify(component.get("v.draftData")));
                //console.log('fire exist legis event');
                //console.log('existLegislations:'+JSON.stringify(rows));
                component.set("v.loaded", false);
                var existLegisEvnt = $A.get("e.c:existLegislationEvent");
                existLegisEvnt.setParams({ "existLegislations" : rows});
                existLegisEvnt.fire();
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
    
    //add New Legislation in the Case / Notic Legislation table
    addLegislation : function(component,event){
        let noticeId = component.get('v.noticeId');
        let newLeg = event.getParam("selectedLegislation");
        let leg = ({
            'Case_Legislative_Reference__c' : newLeg.Id,
            'LegislationName': newLeg.Legislation__r.Legislation_Name__c,
            'Description':newLeg.Legislation__r.Description__c,
            'ScheduleSectionClauseRule' :newLeg.Legislation__r.Schedule_Section_Clause_Rule__c,
            'SubSectionClause': newLeg.Legislation__r.Sub_Section_Clause__c,
            'Comment__c' : '',
            'Notice_record__c' : noticeId,
            'Legislation__c' : newLeg.Legislation__c,
            'Section_Description__c' : newLeg.Legislation__r.Section__c,
            'Direction__c': newLeg.Legislation__r.Direction__c,
            'Recommendation__c': newLeg.Legislation__r.Recommendation__c,
            'Remediation__c': newLeg.Legislation__r.Remediation__c,
            'Status__c' : 'Active',
            'Reason_for_Change__c' : '',
            'actionLabel':'Remove',
            'actionTitle':'Click to Remove',
            'actionIcon' : 'utility:close',
            'actionName' : 'Remove'
        })
        //console.log('leg:'+JSON.stringify(leg));
        let tableLeg = component.get("v.data");
        let updateLeg = tableLeg.concat(leg);
        component.set("v.data",updateLeg);
        //console.log('table data: '+JSON.stringify(component.get("v.data")));
        
        let draftLeg = component.get("v.draftData");
        let updateDraftLeg = [];
        if(draftLeg == null){
            draftLeg = leg;
            updateDraftLeg = draftLeg;
        } else {
            updateDraftLeg = draftLeg.concat(leg);
        }
        //updateDraftLeg = draftLeg.concat(leg);
        component.set("v.draftData",updateDraftLeg);
    }, 
        
    deleteLegislation : function(component, event){
        let rowVal = component.get("v.selectedRow");
        let draftData = component.get("v.draftData");
        
        if(rowVal){
            component.set("v.isModalOpen", false);
            let updatedRow =JSON.stringify(new Array(rowVal));
            //console.log('updatedRow: '+updatedRow);
            let action = component.get('c.deleteNoticeLegislation');
            
            action.setParams({
                "noticeLegislation" : updatedRow
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.loaded", false);
                    this.showToastMsg('','Legislation Deleted','success');
                  
                    component.set('v.draftData',draftData);	
                    let data = component.get("v.data");	
                    let dataMap = new Map(data.map(i => [i.Legislation__c, i]));	
                    
                    let existLeg = component.get("v.existingNoticeLegislation");	
                    let existMap = new Map(existLeg.map(i => [i.Legislation__c, i]));	
                    
                    if(dataMap.has(rowVal.Legislation__c)){	
                        dataMap.delete(rowVal.Legislation__c);	
                    }	
                    let finalData = new Array();	
                    dataMap.forEach(function(dval,index){	
                        finalData.push(dval);	
                    });	
                    
                    if(existMap.has(rowVal.Legislation__c)){	
                        existMap.delete(rowVal.Legislation__c);	
                    }	
                    let existData = new Array();	
                    existMap.forEach(function(dval,index){	
                        existData.push(dval);	
                    });	
                    
                    component.set("v.data",finalData);
                    component.set("v.existingNoticeLegislation",existData);
                    //console.log('existData: '+JSON.stringify(existData));
                    var existLegisEvnt = $A.get("e.c:existLegislationEvent");
                    existLegisEvnt.setParams({ "existLegislations" : existData });
                    existLegisEvnt.fire();
                    let refreshCardsEvent = $A.get("e.c:refreshCardsEvent");
                    refreshCardsEvent.fire();
                }else if(state === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            this.showToastMsg('Error',errors[0].message,'error');
                        }
                    } else {
                        console.log("Unknown error");
                        this.showToastMsg('Error','Unknown Error','error');
                    }
                }
            });
            $A.enqueueAction(action);            
        }else {
            component.set("v.isModalOpen", true);
        }
    },
    
    //Pass on the existing Case /Notic Legislation information to the Search Component
    invokeExistingLegislationEvt : function(component,event){
        let existingLeg = component.get('v.existingNoticeLegislation');
        
        if(existingLeg.length >0){
            let exiLeg = [];
            for(let i=0;i<existingLeg.length;i++){
                let eL = {
                    'Id' : existingLeg[i].Legislation__c,
                    'LegislationName' : existingLeg[i].LegislationName
                }
                exiLeg.push(eL);
            }
            //console.log('exiLeg :'+ JSON.stringify(exiLeg));
            var existLegisEvnt = $A.get("e.c:existLegislationEvent");
            existLegisEvnt.setParams({ "existLegislations" : exiLeg });
            existLegisEvnt.fire();
            //console.log('exiLeg fired');
        } else {
            //console.log('No Existing Leg record present');
        }
    },
    
    //Undo adding of any Legislation to Case/Notic Legislation table
    cancelChange : function(component,event){
        component.set("v.draftData",new Array());
        this.loadLegislation(component,event);
        let existingLeg = component.get("v.existingNoticeLegislation");
        component.set("v.data",existingLeg);
        //console.log('existing Case Legislation:'+JSON.stringify(existingLeg));
        var cancelLegisEvnt = $A.get("e.c:cancelChangesEvent");
        cancelLegisEvnt.fire();
    },
    
    //Save/Update the changes that are made in the Case/Notic 
    saveChange : function(component,draftValues){
        
        let validLegislation = this.validateLegislation(component,draftValues);
        // If validation is succesfull then perform upsert operation
        var toast_title = '';
        var toast_message = 'Legislation Changes Saved';
        var toast_type = 'success';
        let strdraftData = JSON.stringify(component.get("v.draftData"));
        let action = component.get('c.saveNoticeLegislation');
        action.setParams({
            "noticeLegislation" : strdraftData
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.draftData',new Array());
                component.set("v.loaded", false);
                this.loadLegislation(component,event);
                this.showToastMsg(toast_title,toast_message,toast_type);
                var saveLegisEvnt = $A.get("e.c:saveChangesEvent");
                saveLegisEvnt.fire();
                let refreshCardsEvent = $A.get("e.c:refreshCardsEvent");
                refreshCardsEvent.fire();
            }else if(state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        //this.showToastMsg('Error',errors[0].message,'error');
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    //Validate and update inline edits for the row in the Case/Notice legislation table
    validateLegislation : function(component,draftValues){
        const existLegis = component.get("v.existingNoticeLegislation");
        let draftData = component.get("v.draftData");        
        let draftValuesMap = new Map();
        
        //Check if there are any change in the table of Legislations
        if(draftValues.length > 0){            
            draftValues.forEach(function(dVal){
                draftValuesMap.set(dVal.Legislation__c,dVal);
            });
        }
        
        //Check if there are any new Legislation rows added and inline edited
        if(draftData.length >0){
            var draftDataMap = new Map(draftData.map(i => [i.Legislation__c, i]));
            var dataCopyMap = new Map();
            
            draftValuesMap.forEach(function(dval,index) { 
                if(draftDataMap.has(index)){
                    let dataVal = draftDataMap.get(index);
                    let dataCopy = Object.assign({},dataVal);
                    for(let key in dval){
                        let dVal = dval[key];
                        let ddtVal = dataCopy[key];
                        if(dVal != ddtVal || (typeof dataCopy[key] === 'undefined')){
                            dataCopy[key] = dVal;
                        }
                    }
                    dataCopyMap.set(dataCopy.Legislation__c,dataCopy);
                }             
            });
            
            dataCopyMap.forEach(function(dval,index){
                draftDataMap.set(index,dval);
            });
            
            let finalDraftData = new Array();
            
            draftDataMap.forEach(function(dval,index){
                finalDraftData.push(dval);
            });
            
            component.set("v.draftData",finalDraftData);
        } 
        
        //Check if any existing Legislation rows are inline edited
        if(existLegis.length > 0){
            var exisValuesMap = new Map(existLegis.map(i => [i.Legislation__c, i]));
            
            draftValuesMap.forEach(function(dval,index) { 
                if(exisValuesMap.has(index)){
                    let existVal = exisValuesMap.get(index);
                    let existCopy = Object.assign({},existVal);
                    for(let key in dval){
                        let dVal = dval[key];
                        let eVal = existCopy[key];
                        if(dVal != eVal || (typeof existCopy[key] === 'undefined')){
                            existCopy[key] = dVal;
                        }
                    }
                    draftData = (component.get("v.draftData"));
                    draftData.push(existCopy);
                    component.set("v.draftData",draftData);
                }
            });
        } 
    },
    
    //Open reason for Change model window
    openModel: function(component) {
        component.set("v.isModalOpen", true);
        /*setTimeout(function(){ 
            component.find("reason").focus();
        }, 100);*/
    },
    
    //Open reason for Change model window
    removeRow: function(component,event) {
        let data = component.get("v.data");
        let draftData = component.get("v.draftData");
        let selectedRow = component.get("v.selectedRow");
        //console.log('selected Raw:'+JSON.stringify(component.get("v.selectedRow")));
        //console.log("before removing ->Data:"+JSON.stringify(component.get("v.data")));
        //console.log("before removing -> draft Data:"+JSON.stringify(component.get("v.draftData")));
        
        //Check if selected row is present in the Data (displayed in table)
        if(data.length >0){
            var dataMap = new Map(data.map(i => [i.Legislation__c, i]));
            if(dataMap.has(selectedRow.Legislation__c)){
                //console.log('removing row :'+selectedRow.Legislation__c)
                dataMap.delete(selectedRow.Legislation__c);
            } 
            let finalData = new Array();
            dataMap.forEach(function(dval,index){
                finalData.push(dval);
            });
            
            //console.log('finalData data:'+JSON.stringify(finalData));
            component.set("v.data",finalData);
        } 
        
        //Check if selected row is present in the draft Data
        if(draftData.length >0){
            var draftDataMap = new Map(draftData.map(i => [i.Legislation__c, i]));
            if(draftDataMap.has(selectedRow.Legislation__c)){
                draftDataMap.delete(selectedRow.Legislation__c);
            } 
            
            let finalDraftData = new Array();
            let data = component.get("v.data");
            
            draftDataMap.forEach(function(dval,index){
                finalDraftData.push(dval);
            });
            
            component.set("v.draftData",finalDraftData);
            //console.log('after removing -> draft Data:'+JSON.stringify(component.get("v.draftData")));
        }
        var addLegEvent = $A.get("e.c:removeLegislationEvent");	
        //console.log('remove Legislation event:');	
        addLegEvent.setParams({"removedLegislation":selectedRow.Legislation__c});	
        addLegEvent.fire();
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
    
})