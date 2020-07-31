({
    doInit : function(component, event, helper) {
        
        console.log('In init');
        helper.getAuthorisation(component,event,helper);
    },
    
 onNoCovidResponse: function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "CovidR0"){
            console.log('Hello');
            component.set("v.NoCovidResponse", "Yes");
        }
        if(selected == "CovidR1"){
            
            component.set("v.NoCovidResponse", "No");
        }
        
    },
    validate  : function(component, event, helper) {
        
        var inputpostalCode = component.get('v.postalcode');
        console.log('Hi'+inputpostalCode );
        if(isNaN(inputpostalCode))
            component.set('v.postalcode', inputpostalCode.substring(0, inputpostalCode.length - 1));
    },
    saveNotifiableForm : function(component, event, helper) {
          var flafnotify= false;
        var button = event.getSource().getLocalId();
        console.log(button);
        component.find(button).set("v.disabled", true);
        
        
        if(!helper.performBlankInputCheck(component, event)) {
            document.querySelector("#OccurrenceForm #generalErrorMsgDiv").style.display = 'none';
            console.log('should work');
            helper.showSpinner(component, event);
            console.log('in saveNotifiableForm controller');
            
            try{
                
                var rawDateTime = component.find("DateTimeValue").get("v.value");
                var rawBecameAwareDateTimeValue = component.find("BecameAwareDateTimeValue").get("v.value");
                

                var today = new Date();    
                
                var occurrenceAwareDate = new Date(rawDateTime);
                var becameAwareDate = new Date(rawBecameAwareDateTimeValue);
                               
                
                //alert(occurrenceAwareDate + '----'+ today);
                if(occurrenceAwareDate.getTime() <= today.getTime()){
                    var checkValidDateInput = $A.localizationService.formatDateTime(rawDateTime, "yyyy-MM-ddTHH:mm:ss");
                    var checkValidBecameAwareDateInput = $A.localizationService.formatDateTime(rawBecameAwareDateTimeValue, "yyyy-MM-ddTHH:mm:ss");
                    console.log('rawDate:'+rawDateTime);
                    var formattedDateTime = rawDateTime;
                    var formattedBecameAwareDateTimeValue = rawBecameAwareDateTimeValue;
                    console.log('ValidDate');
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "message": "Occurrence Date/Time cannot be a future date", 
                        "type": "error",
                        "duration":4000,
                        "mode" : "pester"
                    });
                    
                    toastEvent.fire();
                    component.find(button).set("v.disabled", false);
                    helper.hideSpinner(component, event);
                    return;
                }
                if(becameAwareDate.getTime() <= today.getTime()){
                    var checkValidDateInput = $A.localizationService.formatDateTime(rawDateTime, "yyyy-MM-ddTHH:mm:ss");
                    var checkValidBecameAwareDateInput = $A.localizationService.formatDateTime(rawBecameAwareDateTimeValue, "yyyy-MM-ddTHH:mm:ss");
                    console.log('rawDate:'+rawDateTime);
                    var formattedDateTime = rawDateTime;
                    var formattedBecameAwareDateTimeValue = rawBecameAwareDateTimeValue;
                    console.log('ValidDate');
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "message": "Became Aware Date/Time cannot be a future date", 
                        "type": "error",
                        "duration":4000,
                        "mode" : "pester"
                    });
                    
                    toastEvent.fire();
                    component.find(button).set("v.disabled", false);
                    helper.hideSpinner(component, event);
                    return;
                }
                if(occurrenceAwareDate.getTime() <= becameAwareDate.getTime()){
                    var checkValidDateInput = $A.localizationService.formatDateTime(rawDateTime, "yyyy-MM-ddTHH:mm:ss");
                    var checkValidBecameAwareDateInput = $A.localizationService.formatDateTime(rawBecameAwareDateTimeValue, "yyyy-MM-ddTHH:mm:ss");
                    console.log('rawDate:'+rawDateTime);
                    var formattedDateTime = rawDateTime;
                    var formattedBecameAwareDateTimeValue = rawBecameAwareDateTimeValue;
                    console.log('ValidDate');
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "message": "Became aware Date/time cannot be before the date of the occurrence", 
                        "type": "error",
                        "duration":4000,
                        "mode" : "pester"
                    });
                    
                    toastEvent.fire();
                    component.find(button).set("v.disabled", false);
                    helper.hideSpinner(component, event);
                    return;
                }
            }
            catch(err){
                console.log('invalidDate');
                helper.datetimeError(component,event,helper);
                console.log(button);
                component.find(button).set("v.disabled", false);
                helper.hideSpinner(component, event);
                return;
            }
            
            console.log('formattedDate:'+checkValidDateInput);
            
            //Part B
            /*For DataSan Address Lookup
            var unitType = component.find("Postal-Address-Input").get('v.unitType');
            var street = component.find("Postal-Address-Input").get('v.street');
            var city = component.find("Postal-Address-Input").get('v.city');
            var state = component.find("Postal-Address-Input").get('v.state');
            var postcode = component.find("Postal-Address-Input").get('v.postalcode');
            */
            
            var street = component.find("street").get('v.value');
            var city = component.find("city").get('v.value');
            var state = component.find("state").get('v.value');
            var postcode = component.find("postalcode").get("v.value");
            
         
                   
            
            
            
            //Part B Checkboxes
            var checkboxA = component.get("v.checkbox-A");
            var checkboxB = component.get("v.checkbox-B");
            var checkboxC = component.get("v.checkbox-C");
            var checkboxD = component.get("v.checkbox-D");
            var checkboxE = component.get("v.checkbox-E");
            
            //Part C TextArea
            var occurenceDesc = component.find("fullOccerrenceDescription").get("v.value");
            var contFact = component.find("contributingFactors").get("v.value");
            var followDesc = component.find("followUpDescription").get("v.value");
            
            console.log('--------------------');
            console.log('Date is : '+formattedDateTime);
            console.log('--------------------');
            //console.log('UnitType is : '+unitType);
            console.log('Street is : '+street);
            console.log('City is : '+city);
            console.log('State is : '+state);
            console.log('PostCode is : '+postcode);
            console.log('--------------------');
            console.log('A is : '+checkboxA);
            console.log('B is : '+checkboxB);
            console.log('C is : '+checkboxC);
            console.log('D is : '+checkboxD);
            console.log('E is : '+checkboxE);
            console.log('--------------------');
            console.log('occurenceDesc is : '+occurenceDesc);
            console.log('contFact is : '+contFact);
            console.log('followDesc is : '+followDesc);
            console.log('--------------------');
            
          
            
            if((component.get('v.postalcode')== undefined || component.get('v.postalcode')== null) && (component.get('v.city')== undefined || component.get('v.city')== null)) 
            {
               console.log('no postcode');
                component.find("postalcode").set("v.errors", [{message: 'Please Enter one of them Sururb/Postcode'}]);
                component.find(button).set("v.disabled", false);
                helper.hideSpinner(component, event);
                document.querySelector("#OccurrenceForm #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#generalErrorMsgDiv").scrollIntoView();
                return; 
            }
            
            else if(component.get('v.postalcode')!= undefined || component.get('v.postalcode')!= null ){
                flafnotify = true;
                
               }
            // console.log('length of post code is: '+postcode.length);
            //
            
            if(flafnotify === true)
            {
             var postCodeLenght = postcode.length;

            if (postCodeLenght == 4){
                component.find("postalcode").set("v.errors", null);
                document.querySelector("#OccurrenceForm #generalErrorMsgDiv").style.display = 'none';
            }
            else{
                component.find("postalcode").set("v.errors", [{message: 'Enter 4-digit Postalcode'}]);
                component.find(button).set("v.disabled", false);
                helper.hideSpinner(component, event);
                document.querySelector("#OccurrenceForm #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#generalErrorMsgDiv").scrollIntoView();
                return;
            }
            }  
            if( checkboxA === true || checkboxB === true || checkboxC === true || checkboxD === true || checkboxE === true ){
                console.log('Atleast 1 checkbox selected');
            }
            else{
                console.log('No checkbox selected');
                console.log(button);
                component.find(button).set("v.disabled", false);
                helper.hideSpinner(component, event);
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "message": "Identify the category for this occurrence (select a category under notifiable occurrence category section).", 
                    "type": "error",
                    "duration":4000,
                    "mode" : "pester"
                });
                
                toastEvent.fire();
                return;
            }
            
            var authId = component.get('v.record_Id');
            var contactId = component.get("v.loggedInContactDetails.Id");
            var accountId = component.get("v.selectedAuthorization.Service_Provider__r.Id");
            var ContactName = component.get('v.loggedInContactDetails.Name');
            var accountName = component.get("v.selectedAuthorization.Service_Provider__r.Name");
            var CovidNOResponse= component.get("v.NoCovidResponse");
            var createCase = component.get("c.createNotifiableOccurenceCase");
            var OccurenceCaseDetails = {'authId' : authId,'occurenceDesc' : occurenceDesc,
                                        'contFact' : contFact ,'followDesc' : followDesc,'accId' : accountId,'contactId' : contactId,
                                        'streetadd' : street,'cityadd' : city,'stateadd' : state,'postCodeadd' : postcode,
                                        'no_date' : formattedDateTime,'no_Became_Aware_Date_Time' : formattedBecameAwareDateTimeValue,'a' : checkboxA,'b' : checkboxB,'c' : checkboxC,'d' : checkboxD,'e' : checkboxE,
                                        'contactName' : ContactName , 'accountName' : accountName , 'CovidNO' : CovidNOResponse
                                       };
            
            createCase.setParams({'data' : JSON.stringify(OccurenceCaseDetails)});
            createCase.setCallback(component, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('State is:'+state);
                    console.log('Section Data Save Success');  
                    helper.hideSpinner(component, event);
                    component.set('v.selectedCase',JSON.parse(response.getReturnValue()));
                    
                    var saveAndCloseModal= component.getEvent("closeModalOnSuccess");
                    saveAndCloseModal.fire();
                    
                }
                else if (state === "INCOMPLETE") {
                    console.log(Incomplete);
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        console.log(errors);
                        helper.hideSpinner(component, event);
                        console.log(button);
                        component.find(button).set("v.disabled", false);
                        
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "message": "Error while saving details. Please contact System Admin.", 
                            "type": "error",
                            "duration":4000,
                            "mode" : "pester"
                        });
                        
                        toastEvent.fire();
                        
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        }
                        else {
                            console.log("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(createCase);      
            return; 
        }
        else {
            document.querySelector("#OccurrenceForm #generalErrorMsgDiv").style.display = 'none';
            document.querySelector("#OccurrenceForm #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#OccurrenceForm #generalErrorMsgDiv").scrollIntoView();
            console.log('Incomplete input.');
            console.log(button);
            component.find(button).set("v.disabled", false);
            setTimeout(function(){ document.querySelector("#OccurrenceForm #generalErrorMsgDiv").style.display = 'none'; }, 5000);
        }
    },
    
    cancelForm : function(component, event, helper) {
        console.log('Modal Closed');
        var disableModal = component.getEvent("showform");
        disableModal.fire();
    },
    
    clickCheckbox: function(component, event, helper){
        console.log('From'+event.target.id);
        var getCheckbox = event.target.id;
        if  (getCheckbox === 'checkbox-A'){
            var a = component.get('v.checkbox-A');
            if(a === false){
                component.set('v.checkbox-A',true);
            }
            else{
                component.set('v.checkbox-A',false);
            }
        }
        if  (getCheckbox === 'checkbox-B'){
            var a = component.get('v.checkbox-B');
            if(a === false){
                component.set('v.checkbox-B',true);
            }
            else{
                component.set('v.checkbox-B',false);
            }
        }
        if  (getCheckbox === 'checkbox-C'){
            var a = component.get('v.checkbox-C');
            if(a === false){
                component.set('v.checkbox-C',true);
            }
            else{
                component.set('v.checkbox-C',false);
            }
        }
        if  (getCheckbox === 'checkbox-D'){
            var a = component.get('v.checkbox-D');
            if(a === false){
                component.set('v.checkbox-D',true);
            }
            else{
                component.set('v.checkbox-D',false);
            }
        }
        if  (getCheckbox === 'checkbox-E'){
            var a = component.get('v.checkbox-E');
            if(a === false){
                component.set('v.checkbox-E',true);
            }
            else{
                component.set('v.checkbox-E',false);
            }
        }        
    }
})