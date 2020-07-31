({
	fetchHistoryHelper : function(component, event, helper) {
        var authID = component.get('v.RelatedAuthID');
        console.log("Current Authorisation ID is : " + authID);
        
		var action = component.get("c.getAuthHistories");
            action.setParams({
                "authID": authID
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    for (var i = 0; i < rows.length; i++) {
                        var row = rows[i];
                        console.log(row);
                        if (row.CreatedBy) {
                            console.log(row.CreatedBy);
                            row.USER = row.CreatedBy.Name;
                        }
                       if (row.Field){
                            if(row.Field === "Status__c"){
                                row.Field = 'Status';
                        }
                       
				if (row.Field){
                               if(row.Field === "Authorisation_Type__c"){
                                  row.Field = 'Authorisation Type';
                            }
				}
                           				if (row.Field){
                               if(row.Field === "Agency__c"){
                                  row.Field = 'Agency';
                            }
				}  
				
				if (row.Field){
                               if(row.Field === "BSB_Number__c"){
                                  row.Field = 'BSB Number';
                            }
				}  
				
				if (row.Field){
                               if(row.Field === "Condition_Type__c"){
                                  row.Field = 'Condition Type';
                            }
				}  
				
				if (row.Field){
                               if(row.Field === "Decision_Made_By__c"){
                                  row.Field = 'Decision Made By';
                            }
				}  
				
				if (row.Field){
                               if(row.Field === "First_Issued_Date__c"){
                                  row.Field = 'First Issued Date';
                            }
				}  
				
				if (row.Field){
                               if(row.Field === "Licence_Fee__c"){
                                  row.Field = 'Licence Fee';
                            }
				}  
				
				if (row.Field){
                               if(row.Field === "Operation_Area__c"){
                                  row.Field = 'Operation Area';
                            }
				}  
				
				if (row.Field){
                               if(row.Field === "Payment_Frequency__c"){
                                  row.Field = 'Payment Frequency';
                            }
				}  
				
				if (row.Field){
                               if(row.Field === "Plate_Number__c"){
                                  row.Field = 'Plate Number';
                            }
				} 
				if (row.Field){
                               if(row.Field === "Service_Provider__c"){
                                  row.Field = 'Account Name';
                            }
				}
				if (row.Field){
                               if(row.Field === "Agreement_Type__c"){
                                  row.Field = 'Agreement Type';
                            }
				}
				if (row.Field){
                               if(row.Field === "Authorisation_Number__c"){
                                  row.Field = 'Authorisation Number';
                            }
				}
				if (row.Field){
                               if(row.Field === "Decision_Date__c"){
                                  row.Field = 'Decision Date';
                            }
				}
				if (row.Field){
                               if(row.Field === "End_Date__c"){
                                  row.Field = 'End Date';
                            }
				}
				if (row.Field){
                               if(row.Field === "Licence_Class__c"){
                                  row.Field = 'Licence Class';
                            }
				}
				if (row.Field){
                               if(row.Field === "Licence_Type__c"){
                                  row.Field = 'Licence Type';
                            }
				}
				if (row.Field){
                               if(row.Field === "Start_Date__c"){
                                  row.Field = 'Start Date';
                            }
				}
				if (row.Field){
                               if(row.Field === "OwnerId"){
                                  row.Field = 'Owner';
                            }
				}
				
                
                	if (row.Field){
                               if(row.Field === "Operating_Locations__c"){
                                  row.Field = 'Operating Locations';
                            }
				}
                           
                           
                            
                            
                        }
                        console.log(row.Field);
                        console.log(row);
                    //   row.createdbyName = row.createdby.Name;
            		}
            		component.set('v.AuthorisationHistory', rows)
                }
           
            });
        	console.log('Response ---->'+component.get("v.AuthorisationHistory"));
             $A.enqueueAction(action);
        }
    

})