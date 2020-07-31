({
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    
    getCancelationReasons : function(component, event){
        var action = component.get("c.fetchCancelationReasonsMPicklist");
        var inputsel = component.find("InputSelectMultiple");
        var opts=[];
        action.setCallback(this, function(a) {
            console.log(a.getState());
            for(var i = 0; i < a.getReturnValue().length; i++){
                console.log()
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            console.log(inputsel);
            inputsel.set('v.options', opts);
            
        });
        $A.enqueueAction(action);
    },
    
    createTaxiSuspensionCase : function(component, event){
        this.showSpinner(component,event);
        console.log('Creating a case');
        var authId = component.get('v.recordId');
        console.log('authId is:'+authId);
        
        var reason = component.find('InputSelectMultiple').get('v.value');
        console.log('with reasons :'+reason);
        var licenseClass = component.get('v.selectedAuthorization.Licence_Class__c');
        
        if(licenseClass === 'TX03WAT'){
            console.log('Testing TX03WAT');
                var createCase = component.get('c.createTaxiLicenceCancellationCaseTX03WAT');
                createCase.setParams({'authId' : authId , 'reason' : reason});
                createCase.setCallback(this,function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        console.log("Got Response: "+response.getReturnValue());
                        var caseId = response.getReturnValue();
                        this.hideSpinner(component, event);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'pester',
                            "title" : "Success",
                            message: 'Taxi Cancellation Case is created with Case Number: '+caseId,
                            type : "success"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire()
                        
                        $A.get("e.force:refreshView").fire();
                        //setTimeout(function(){ window.location.href= 'https://'+domain+'/'+caseId ; }, 3000);
                      }
                    else {
                        console.log('failed');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'pester',
                            "title" : "Error",
                            message: 'Unable to create Case',
                            type : "error"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire()
                    }
                });
                $A.enqueueAction(createCase);
            	this.hideSpinner(component,event);
        }
        else if(licenseClass === 'TX03'){
            console.log('TX03');
            this.hideSpinner(component,event);
        }
            else{
                console.log('Other');
                var createCase = component.get('c.createTaxiLicenceCancellationCase');
                
                createCase.setParams({'authId' : authId , 'reason' : reason});
                createCase.setCallback(this,function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        console.log("Got Response: "+response.getReturnValue());
                        var caseId = response.getReturnValue();
                        //console.log('New Case Id is: '+caseId);
                        //var domain = window.location.hostname;
                        //console.log(domain);
                        this.hideSpinner(component, event);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'pester',
                            "title" : "Success",
                            message: 'Taxi Cancellation Case is created with Case Number: '+caseId,
                            type : "success"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire()
                        
                        $A.get("e.force:refreshView").fire();
                        //setTimeout(function(){ window.location.href= 'https://'+domain+'/'+caseId ; }, 3000);
                        
                        
                    }
                    else {
                        console.log('failed');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'pester',
                            "title" : "Error",
                            message: 'Unable to create Case',
                            type : "error"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire()
                    }
                });
                $A.enqueueAction(createCase);
             }
      }
})