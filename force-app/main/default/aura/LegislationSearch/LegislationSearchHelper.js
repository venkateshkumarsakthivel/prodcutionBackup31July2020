({ 
    search : function(component, event) {
        let searchStr = component.get("v.searchString");
        let searchSec = component.get("v.searchSection");
        let exclusionRecordType = component.get("v.recordtype");
        let existingLegis = component.get("v.existingLegislation");
        const existingLegisMap = new Map(existingLegis.map(obj =>[obj.Id,obj]));
        let addedLegis = component.get("v.addedLegislation");
        const addedLegisMap = new Map(addedLegis.map(obj =>[obj.Id,obj]));
        
        if(searchStr.trim().length > 2){
            component.set("v.searchStringLength",true);
            component.set("v.loaded", true);
            let action = component.get("c.searchForRecords");
            action.setParams({
                "searchString" : searchStr,
                "searchSection" : searchSec,
                "exclusionRT" : exclusionRecordType
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.loaded",false);
                    let responseValue = response.getReturnValue();
                    let valLeg = [];
                    
                    responseValue.map(function(resRow) {
                        if(addedLegisMap.has(resRow.Id)||existingLegisMap.has(resRow.Id)){
                            //don't add the new list if already present
                        } else {
                            //adding to new List if not in the existing or added Legislation 
                            valLeg.push(resRow);
                        } 
                    });
                    
                    if(existingLegis.length == 0 && addedLegis.length == 0){    
                        component.set("v.matchingLegislation",response.getReturnValue());
                    } else {
                        component.set("v.matchingLegislation",valLeg);
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
            $A.enqueueAction(action);
        } else if($A.util.isEmpty(component.get('v.searchString'))){
            component.set("v.searchStringLength",false);
            component.set('v.matchingLegislation',null);            
        }else{
            component.set("v.searchStringLength",false);
        }
    },
    
    invokedLegislation : function(component,event){
        let action = event.getParam('action');
        var row = event.getParam('row');
        
        let newLegAdded = JSON.parse(JSON.stringify(row));
        let addLeg = component.get('v.addedLegislation');
        
        addLeg.push(newLegAdded);
        let addLeg2 = component.get('v.addedLegislation');
        
        var data = component.get('v.matchingLegislation');
        
        var validLeg = []
        data = data.map(function(rowData) {
            if (rowData.Id !== row.Id) {
                validLeg.push(rowData);
            }
        });
        
        component.set("v.matchingLegislation", validLeg);
        
        var addedRows = component.get('v.addedLegislationCount');
        addedRows +=1;
        component.set('v.addedLegislationCount', addedRows); 
        
        var addLegEvent = $A.get("e.c:AddLegislationEvent");
        //console.log('addLegEvent:'+addLegEvent);
        addLegEvent.setParams({"selectedLegislation":row});
        //console.log('addLegEvent fired');
        addLegEvent.fire();
        
    },

    removeLegislation : function(component,event){
        let addedRowsCnt = component.get('v.addedLegislationCount');
        addedRowsCnt -=1;
        component.set('v.addedLegislationCount', addedRowsCnt); 
        
        let removeLegis = event.getParam("removedLegislation");
        
        let addedLeg = component.get("v.addedLegislation");
        var addedLegMap = new Map(addedLeg.map(i => [i.Id, i]));
        
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
        let exLegis = event.getParam("existLegislations");
        component.set("v.existingLegislation",exLegis);
        this.search(component, event);
    },
    
    cancelChanges : function(component,event){
        component.set("v.addedLegislationCount",0);
        component.set("v.addedLegislation",'');
        this.search(component, event);
    },
    
    
});