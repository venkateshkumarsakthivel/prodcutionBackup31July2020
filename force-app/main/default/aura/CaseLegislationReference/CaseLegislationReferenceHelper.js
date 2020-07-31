({
    
    //Load Case Legislation based on the Case Id and show in the table
    loadLegislation  : function(component,event) {
        //console.log('loadLegislation');
        let caseId = component.get('v.caseId');
        let action = component.get('c.loadCaseLegislation');
        component.set("v.loaded", true);
        action.setParams({
            "caseId" : caseId
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
                    }if(row.Id){
                        row.actionLabel = 'Deactivate';
                        row.actionTitle = 'Click to deactivate';
                        row.actionIcon='utility:delete';
                        row.actionName = 'Delete';
                    } else{
                        //console.log('No Row');
                    }
                }
                component.set("v.existingCaseLegislature",rows);
                component.set("v.data",rows);
                component.set("v.loaded", false);
            }
            else if(state === "ERROR") {
                component.set("v.loaded", false);
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
        let caseId = component.get('v.caseId');
        let newLeg = event.getParam("selectedLegislation");
        let leg = ({
            'LegislationName': newLeg.Legislation_Name__c,
            'Description':newLeg.Description__c,
            'Comment__c' : '',
            'Case__c' : caseId,
            'Legislation__c' : newLeg.Id,
            'ScheduleSectionClauseRule':newLeg.Schedule_Section_Clause_Rule__c,
            'SubSectionClause':newLeg.Sub_Section_Clause__c,
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
        
        let existLeg = component.get("v.existingCaseLegislature");

        if(draftLeg.length <=0 && existLeg.length<=0){
            leg.Primary__c = true;
        }
        let updateDraftLeg = [];
        if(draftLeg.length <=0){
            draftLeg = leg;
            updateDraftLeg = draftLeg;
        } else {
            updateDraftLeg = draftLeg.concat(leg);
        }
        //updateDraftLeg = draftLeg.concat(leg);
        component.set("v.draftData",updateDraftLeg);
    }, 
    
    updateLegislation : function(component, event){
        let reason = component.find("reason").get("v.value");
        let rowVal = component.get("v.selectedRow");
        let draftData = component.get("v.draftData");
        if(reason){
            component.set("v.isModalOpen", false);           
            rowVal.Reason_for_Change__c = reason;
            rowVal.Status__c='Inactive';
            rowVal.Primary__c= false;
            let updatedRow =JSON.stringify(new Array(rowVal));
            let action = component.get('c.saveCaseLegislation');
            component.set("v.loaded", true);
            action.setParams({
                "caseLegislation" : updatedRow
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    this.showToastMsg('','Legislation Reference Deactivated','success');
                    component.set("v.loaded", false);
                    component.set('v.draftData',draftData);
                    let data = component.get("v.data");
 					let dataMap = new Map(data.map(i => [i.Legislation__c, i]));
                    
                    let existLeg = component.get("v.existingCaseLegislature");
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
                    component.set("v.existingCaseLegislature",existData);
                    var existLegisEvnt = $A.get("e.c:existLegislationEvent");
                    existLegisEvnt.setParams({ "existLegislations" : existData });
                    existLegisEvnt.fire();
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
    
    loadReasonforChange : function(component, event){
        var pickvar = component.get("c.getPickListValuesIntoList");
        pickvar.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var list = response.getReturnValue();
                component.set("v.picvalue", list);
            }
            else if(state === 'ERROR'){
                //var list = response.getReturnValue();
                //component.set("v.picvalue", list);
                alert('ERROR OCCURED.');
            }
        })
        $A.enqueueAction(pickvar);
    },
    
    //Pass on the existing Case /Notic Legislation information to the Search Component
    invokeExistingLegislationEvt : function(component,event){
        let existingLeg = component.get('v.existingCaseLegislature');
        
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
        let existingLeg = component.get("v.existingCaseLegislature");
        component.set("v.data",existingLeg);
        //console.log('existing Case Legislation:'+JSON.stringify(existingLeg));
        var cancelLegisEvnt = $A.get("e.c:cancelChangesEvent");
        cancelLegisEvnt.fire();
    },
    
    //Save/Update the changes that are made in the Case/Notice
    saveChange : function(component,draftValues){
        var toast_title = '';
        var toast_message = 'Legislation Changes Saved';
        var toast_type = 'success';
        let validLegislation = this.validateLegislation(component,draftValues);
        // If validation is succesfull then perform upsert operation
        let strdraftData = JSON.stringify(component.get("v.draftData"));
        let action = component.get('c.saveCaseLegislation');
        component.set("v.loaded", false);
        action.setParams({
            "caseLegislation" : strdraftData
        });
        action.setCallback(this,function(response){
            console.log('saveChange callback received');
            component.set("v.loaded", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.draftData',new Array());
                this.loadLegislation(component,event);                
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
        $A.enqueueAction(action);
        this.showToastMsg(toast_title,toast_message,toast_type);
        $A.get('e.force:refreshView').fire();
    },
    
    
    //Validate and update inline edits for the row in the Case/Notice legislation table
    validateLegislation : function(component,draftValues){
        const existLegis = component.get("v.existingCaseLegislature");
        let draftData = component.get("v.draftData");
        
        let draftValuesMap = new Map();
        
        //Check if there are any change in the table of Legislations
        if(draftValues.length > 0){            
            draftValues.forEach(function(dVal){
                draftValuesMap.set(dVal.Legislation__c,dVal);
                //console.log('draftValues :'+dVal.Legislation__c);
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
        setTimeout(function(){ 
            component.find("reason").focus();
        }, 100);
    },
    
    //Open reason for Change model window
    removeRow: function(component,event) {
        let data = component.get("v.data");
        let draftData = component.get("v.draftData");
        let selectedRow = component.get("v.selectedRow");

        if(data.length >0){
            var dataMap = new Map(data.map(i => [i.Legislation__c, i]));
            if(dataMap.has(selectedRow.Legislation__c)){
                //console.log('removing row :'+selectedRow.Legislation__c);
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