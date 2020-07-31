({
    retrieveConditions : function(component, event, helper) {
        
        console.log(component.get("v.recordId"));
        component.set('v.customConditions', '[]');
        
        var isValidAction = component.get('c.validToAddConditions');
        isValidAction.setParams({
            authRecordId : component.get("v.recordId")
        });
        isValidAction.setCallback(this, function(response){
            
            var state =  response.getState();
            if(state == 'SUCCESS') {
                
               component.set("v.isValidToAddConditions", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(isValidAction);
        
        var action = component.get('c.getConditions');
        action.setParams({
            authRecordId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            
            var state =  response.getState();
            if(state == 'SUCCESS') {
                
                console.log(state);
                console.log(response.getReturnValue());
                component.set("v.aspConditions", response.getReturnValue());
                
            }else{
                
                console.log(state);
            }
        });
        
        $A.enqueueAction(action);
    },
    attachASPConditions : function(component, event, helper){
        
        document.querySelector("#generalErrorMsgDiv").style.display = 'none';
        document.querySelector("#generalErrorMsgDiv").scrollIntoView();
        
        var hasRequiredFieldMissing = false;
        console.log('conditions to be attached');
        var aspConditions = component.get('v.aspConditions');
        
        console.log(aspConditions);
        var selectedAspConditions = [];
        var unSelectedAspConditions = [];
        for(var index = 0; index < aspConditions.length; index++){
            
            console.log(aspConditions[index]);
            var element = document.getElementById(index);
            console.log('element: ' + element);
            
            if(element) {
                
                console.log('Checked: ' + element.checked);
                console.log('Elem: ' + aspConditions[index]["Condition_Details__c"]);
                console.log('Master: ' + aspConditions[index]["Master_Condition__c"]);
                if(aspConditions[index]["Master_Condition__c"] == null) {
                    
                    console.log('Index is: '+index);
                    document.getElementsByClassName("required_input_"+index)[0].innerHTML = "";
                    document.getElementsByClassName("condition_detail_error_"+index)[0].className = document.getElementsByClassName("condition_detail_error_"+index)[0].className.replace(new RegExp('(?:^|\\s)'+'has-error'+'(?:\\s|$)'), ' ');
                    
                }
                
                if(element.checked && aspConditions[index]["Master_Condition__c"] == null) {
                    
                    if(aspConditions[index]["Condition_Details__c"] != '') {                        
                        selectedAspConditions.push(aspConditions[index]);
                    }
                    else{
                        
                        hasRequiredFieldMissing = true;
                        console.log("======"+hasRequiredFieldMissing);
                        document.getElementsByClassName("required_input_"+index)[0].innerHTML = "Required input";
                        document.getElementsByClassName("condition_detail_error_"+index)[0].className = document.getElementsByClassName("condition_detail_error_"+index)[0].className + ' has-error';
                    }
                    
                    
                }
                else if(element.checked && aspConditions[index]["Master_Condition__c"] != null) {
                    
                    selectedAspConditions.push(aspConditions[index]);
                }
                else if(aspConditions[index]["Id"] != undefined){
                    
                    unSelectedAspConditions.push(aspConditions[index]);
                }                
            }            
        }
        
        if(hasRequiredFieldMissing) {
            
            console.log('Showing Toast');
            
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#generalErrorMsgDiv").scrollIntoView();
        }
        else {
            console.log(selectedAspConditions);
            console.log(unSelectedAspConditions);
            console.log(aspConditions);
            var authRecordId = component.get("v.recordId")
            var action = component.get('c.attachConditions');
            action.setParams({
                "unSelectedConditions" : JSON.stringify(unSelectedAspConditions), "selectedConditions" : JSON.stringify(selectedAspConditions), "authRecordId" : authRecordId
            });
            
            action.setCallback(this, function(response){
                
                var state =  response.getState();
                
                if(state == 'SUCCESS'){
                    
                    console.log(state);  
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Condition(s) have been updated successfully.",
                        "type":"success",
                        "duration":10000
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                } else if (state === "ERROR"){
                    
                    var errors = response.getError();
                    if (errors){
                        
                        if (errors[0] && errors[0].message){  
                            console.log("Error message: " +errors[0].message);
                            console.log(errors);
                        }
                    } else{
                        
                        console.log("Unknown error");
                    }
                }  
            });
            
            $A.enqueueAction(action);
        }
    },
    addCondition : function(component, event, helper){
        
        var condition = {};
        condition["Condition_Details__c"] = '';
        condition["Authority__c"] = component.get('v.recordId');
        condition["Master_Condition__c"] = null;
        
        var existingConditions = component.get('v.aspConditions');
        console.log(existingConditions);
        existingConditions.push(condition);
        
        component.set('v.aspConditions', existingConditions);
    },
    cancelModal : function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
    }
})