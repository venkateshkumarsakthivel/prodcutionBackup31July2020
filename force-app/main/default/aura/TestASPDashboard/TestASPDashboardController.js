({
    doInit : function (component, event, helper) {       
        component.set("v.sortDriverAsc", true);
        component.set("v.sortDriverField", "Last_Name__c");
        component.set("v.sortVehicleAsc", true);
        component.set("v.sortVehicleField", "Plate_Number__c");
        component.set("v.currentGrid", "Drivers");
        component.set("v.dvdDriversMap", {});
        component.set("v.dvdVehiclesMap", {});
        component.set("v.recordCountToLoadOnScroll", 15);
        
        helper.loadDrivers(component, event);
    },
    refreshDrivers : function (component, event, helper) {
        
        component.find("driverSearch").set("v.value", "");
        
        $('input[type=checkbox]:checked').removeAttr('checked');
        helper.loadDrivers(component, event);
        
        component.set("v.currentGrid", "Drivers");
        
    },
    refreshVehicles : function (component, event, helper) {
        
        component.find("vehicleSearch").set("v.value", "");
        
        $('input[type=checkbox]:checked').removeAttr('checked');
        helper.loadVehicles(component, event);
        
        component.set("v.currentGrid", "Vehicles");
    },
    uploadDrivers : function(component, event, helper) {
        
        console.log("Upload Drivers");
        $A.createComponent(
            "c:BulkUploadDrivers",
            {
                
            },
            function(newComponent, status, errorMessage) {
                
                console.log(status);
                if (status === "SUCCESS") {
                    component.set("v.body", newComponent);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        
    },
    uploadVehicle : function(component, event, helper) {
        
        console.log("Upload Vehicles");
        $A.createComponent(
            "c:BulkUploadVehicles",
            {
                
            },
            function(newComponent, status, errorMessage){
                
                console.log(status);
                if (status === "SUCCESS") {
                    component.set("v.body", newComponent);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }                
            }
        );
        
    },    
    renderfiltersHandler : function(component, event, helper) {
        
        console.log('event handler renderfilter');
        var renderDrivers = event.getParam("renderDrivers");
        var renderVehicles = event.getParam("renderVehicles");
        var whichButton = event.getParam("whichButton");
        
        console.log("Which button: "+whichButton);
        
        component.set("v.sortDriverAsc", true);
        component.set("v.sortDriverField", "");
        component.set("v.sortVehicleAsc", true);
        component.set("v.sortVehicleField", "");
        component.find("selectAllDrivers").set("v.value", false);
        component.find("selectAllVehicles").set("v.value", false);
        component.find("driverSearch").set("v.value", "");
        component.find("vehicleSearch").set("v.value", "");
        
        if(whichButton == "Drivers") {
            
            
            helper.loadDrivers(component, event);
            
        } else if(whichButton == "Vehicles") {
            
            
            helper.loadVehicles(component, event); 
            
        } else if(whichButton == "DVDLogs") {
            
            console.log('DVD Logs Page...');            
        }
        
        component.set("v.currentGrid", whichButton);
        console.log('event handler renderfilter complete');        
    },
    runDriversDVD : function(component, event, helper){
        
        var selectedIds = component.get("v.selectedDVDRecords");
        console.log('No. of records selected: '+selectedIds.length);
        
        if(selectedIds.length == 0) {
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No records selected.",
                "type": "error"
            });
            toastEvent.fire();
        }
        else {
            
            $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "You are about to run "+selectedIds.length+" driver(s). Do you want to continue?",
                    "entityType": 'Driver',
                    "confirmType": 'Run DVD'
                },
                function(newComponent, status, errorMessage) {
                    
                    console.log(status);
                    //Add the new button to the body array
                    if (status === "SUCCESS") {                        
                        component.set("v.body", newComponent);
                        
                    } else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                        // Show offline error
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }  
                }
            );
        }
    }, 
    runVehiclesDVD : function(component, event, helper){
        
        var selectedIds = component.get("v.selectedDVDRecords");
        console.log('No. of records selected: '+selectedIds.length);
        
        if(selectedIds.length == 0) {
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No records selected.",
                "type": "error"
            });
            toastEvent.fire();
        } else {            
            $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "You are about to run "+selectedIds.length+" vehicle(s). Do you want to continue?",
                    "entityType": 'Vehicle',
                    "confirmType": 'Run DVD'
                },
                function(newComponent, status, errorMessage){
                    console.log(status);
                    //Add the new button to the body array
                    if (status === "SUCCESS") {                        
                        component.set("v.body", newComponent);                        
                    } else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                        // Show offline error
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }                    
                }
            );
        }
    },
    newDriver : function(component, event, helper){
        
        $A.createComponent(
            "c:ManuallyUploadDrivers",
            {
                
            },
            function(newComponent, status, errorMessage){
                console.log(status);
                //Add the new button to the body array
                if (status === "SUCCESS") {                    
                    component.set("v.body", newComponent);                    
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }                
            }
        );
    },
    newVehicle : function(component, event, helper){
        $A.createComponent(
            "c:ManuallyUploadVehicles",
            {
                
            },
            function(newComponent, status, errorMessage){
                console.log(status);
                //Add the new button to the body array
                if (status === "SUCCESS") {                    
                    component.set("v.body", newComponent);                    
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }                
            }
        );
    },
    filterShowAllDrivers: function(component, event, helper){
        
        var masterList = component.get("v.dvdDriverMasterList");
        component.find("driverSearch").set("v.value", "");
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(masterList.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdDriversList', masterList);
            helper.renderDriverTable(component, masterList);
            component.set("v.dvdListBeforeSearch", masterList);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', masterList);
            var tempRecords = masterList.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdDriversList', recordSubsetToLoad);
            helper.renderDriverTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", masterList);
        }
        
        //component.set("v.dvdDriversList", masterList);
        
        component.find("driverSearch").set("v.value", "");
        component.find("selectAllDrivers").set("v.value", false);
        component.set("v.selectedDVDRecords", []);
        helper.activateDriversTab(component, event);    
    },
    filterShowAllVehicles: function(component, event, helper){        
        
        var masterList = component.get("v.dvdVehicleMasterList");
        component.find("vehicleSearch").set("v.value", "");
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(masterList.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdVehiclesList', masterList);
            helper.renderVehicleTable(component, masterList);
            component.set("v.dvdListBeforeSearch", masterList);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', masterList);
            var tempRecords = masterList.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdVehiclesList', recordSubsetToLoad);
            helper.renderVehicleTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", masterList);
        }
        //component.set("v.dvdVehiclesList", masterList);
        
        component.find("vehicleSearch").set("v.value", "");
        component.find("selectAllVehicles").set("v.value", false);
        component.set("v.selectedDVDRecords", []);
        helper.activateVehiclesTab(component, event);
    },
    filterRedDrivers : function(component, event, helper) {
        
        component.find("driverSearch").set("v.value", "");
        component.find("selectAllDrivers").set("v.value", false);
        component.set("v.selectedDVDRecords", []);
        helper.filterRedDrivers(component, event);
    }, 
    filterWhiteDrivers : function(component, event, helper){
        
        component.find("driverSearch").set("v.value", "");
        component.find("selectAllDrivers").set("v.value", false);
        component.set("v.selectedDVDRecords", []);
        helper.filterWhiteDrivers(component, event);
    },
    filterGreenDrivers : function(component, event, helper) {
        
        component.find("driverSearch").set("v.value", "");
        component.find("selectAllDrivers").set("v.value", false);
        component.set("v.selectedDVDRecords", []);
        helper.filterGreenDrivers(component, event);
    }, 
    filterRedVehicles : function(component, event, helper) {
        
        component.find("vehicleSearch").set("v.value", "");
        component.find("selectAllVehicles").set("v.value", false);
        component.set("v.selectedDVDRecords", []);
        helper.filterRedVehicles(component, event);
    }, 
    filterWhiteVehicles : function(component, event, helper) {
        
        component.find("vehicleSearch").set("v.value", "");
        component.find("selectAllVehicles").set("v.value", false);
        component.set("v.selectedDVDRecords", []);
        helper.filterWhiteVehicles(component, event);
    },
    filterGreenVehicles : function(component, event, helper) {
        
        component.find("vehicleSearch").set("v.value", "");
        component.find("selectAllVehicles").set("v.value", false);
        component.set("v.selectedDVDRecords", []);
        helper.filterGreenVehicles(component, event);
    },
    sortDriverColumn: function(component, event, helper) {
        
        console.log(event.currentTarget);
        var columnTitle = event.currentTarget.id;
        var records;
        
        console.log(component.get("v.dvdFullScrollList").length);
        
        if(component.get("v.dvdFullScrollList").length > 0)
         records = component.get("v.dvdFullScrollList");
        else
         records = component.get("v.dvdDriversList");
        
        helper.showSpinner(component, event);
        helper.sortDriverBy(component, columnTitle, records);
        helper.hideSpinner(component, event);
    },
    sortVehicleColumn: function(component, event, helper) {
        
        console.log(event.currentTarget);
        var columnTitle = event.currentTarget.id;
        var records;
        
        if(component.get("v.dvdFullScrollList").length > 0)
         records = component.get("v.dvdFullScrollList");
        else
         records = component.get("v.dvdVehiclesList");
        
        helper.showSpinner(component, event);
        helper.sortVehicleBy(component, columnTitle, records);
        helper.hideSpinner(component, event);
    },
    export : function(component, event, helper){
        
        
        var whatToExport = event.getSource().getLocalId();
        console.log("whatToExport: " +whatToExport);
        
        if(whatToExport == "Drivers Export"){
            var data = component.get("v.dvdDriversList");
            var type = 'Drivers'; 
            helper.exportData(component, event, type, data);
        }
        else{
            var data = component.get("v.dvdVehiclesList");
            var type = 'Vehicles';
            helper.exportData(component, event, type, data);
        }
    },
    confirmDVDRecordDelete: function(component, event, helper) {
        
        var recId;
        
        if(event.currentTarget == undefined)
         recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-RecId");
        else
         recId = event.currentTarget.getAttribute("data-RecId");
        
        console.log('Record to delete: '+recId);
        
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "You are about to delete a record. <br/>Do you want to continue?",
                "recordId": recId,
                "confirmType": "Delete"
            },
            function(newComponent, status, errorMessage){
                console.log(status);
                //Add the new button to the body array
                if (status === "SUCCESS") {                    
                    component.set("v.body", newComponent);                    
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }                
            }
        );
        
    },
    handleDVDRecordDelete: function(component, event, helper) {
        
        helper.showSpinner(component, event);
        
        console.log('Got Event: '+event);
        
        var recordId = event.getParam("recordId");
        console.log(recordId);
        
        var action = component.get("c.dvdRecordDeletion");
        
        action.setParams({
            "recordId": recordId
        });
        
        console.log(action);
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                //Remove only the deleted expense from view
                //var dvdDriverEntities = component.get("v.dvdDriversList");
                
                if(component.get("v.dvdFullScrollList").length > 0)
                  dvdDriverEntities = component.get("v.dvdFullScrollList");
                else
                  dvdDriverEntities = component.get("v.dvdDriversList");
                
                var dvdDriverEntitiesMap = component.get("v.dvdDriversMap");
                var driverItemToDelete = dvdDriverEntitiesMap[recordId];
                var driverItemToDeleteIndex = dvdDriverEntities.indexOf(driverItemToDelete);
                
                dvdDriverEntities.splice(driverItemToDeleteIndex, 1);
                delete dvdDriverEntitiesMap[recordId];
                
                var dvdVehicleEntities = component.get("v.dvdVehiclesList");
                
                if(component.get("v.dvdFullScrollList").length > 0)
                  dvdVehicleEntities = component.get("v.dvdFullScrollList");
                else
                  dvdVehicleEntities = component.get("v.dvdVehiclesList");
                
                var dvdVehicleEntitiesMap = component.get("v.dvdVehiclesMap");
                var vehicleItemToDelete = dvdVehicleEntitiesMap[recordId];
                var vehicleItemToDeleteIndex = dvdVehicleEntities.indexOf(vehicleItemToDelete);
                
                dvdVehicleEntities.splice(vehicleItemToDeleteIndex, 1);
                delete dvdVehicleEntitiesMap[recordId];
                
                //component.set("v.dvdDriversList", dvdDriverEntities);
                //component.set("v.dvdVehiclesList", dvdVehicleEntities);
                if(driverItemToDeleteIndex != -1) {
                 
                    var row = document.getElementById(driverItemToDelete["Id"]);
                    row.parentNode.removeChild(row);
                }
                
                if(vehicleItemToDeleteIndex != -1) {
                 
                    var row = document.getElementById(vehicleItemToDelete["Id"]);
                    row.parentNode.removeChild(row);
                }
                
                component.set("v.dvdDriversMap", dvdDriverEntitiesMap);
                component.set("v.dvdVehiclesMap", dvdVehicleEntitiesMap);
                
                var resultsToast = $A.get("e.force:showToast");
                
                resultsToast.setParams({
                    "title": "Record Deletion",
                    "message": "Record deleted successfully.",
                    "type": "success"
                });
                
                resultsToast.fire();
            }
            else 
                alert('Failed'+recId);
            
            helper.hideSpinner(component, event);
        });
        
        $A.enqueueAction(action);
    },
    editDriverDVDRecord: function(component, event, helper) {
        
        var recId;
        
        if(event.currentTarget == undefined)
         recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-RecId");
        else
         recId = event.currentTarget.getAttribute("data-RecId");
        
        console.log('Record to edit: '+recId);
        
        var lNameInputText = document.getElementById(recId+'_Lname_Output').innerHTML;
        var dlnInputText = document.getElementById(recId+'_DLN_Output').innerHTML;
        var dobInputText = document.getElementById(recId+'_DOB_Output').innerHTML;
        
        var lNameInput = document.getElementById(recId+'_Lname_Input');
        lNameInput.innerHTML = "<input id='" + recId + "lname' maxlength='100' class='input uiInput uiInputText uiInput--default uiInput--input' type='text' prevValue='"+lNameInputText+"' value='"+lNameInputText+"' />";
        var dlnInput = document.getElementById(recId+'_DLN_Input');
        dlnInput.innerHTML = "<input id='" + recId + "licence' maxlength='10' class='input uiInput uiInputText uiInput--default uiInput--input' type='text' prevValue='"+dlnInputText+"' value='"+dlnInputText+"' />";
        var dobInput = document.getElementById(recId+'_DOB_Input');
        dobInput.innerHTML = "<input id='" + recId + "dob' maxlength='10' class='input uiInput uiInputText uiInput--default uiInput--input' type='text' prevValue='"+dobInputText+"' value='"+dobInputText+"' />";
        
        helper.toggleDriverEdit(component, event, recId);
    },
    updateDriverDVDRecord: function(component, event, helper) {
        
        helper.showSpinner(component, event);
        
        var recId;
        
        if(event.currentTarget == undefined)
         recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-RecId");
        else
         recId = event.currentTarget.getAttribute("data-RecId");
        
        console.log('Record to edit: '+recId);
        
        var lName = document.getElementById(recId+'_Lname_Input').getElementsByTagName("input")[0].value;
        var drivingLicenceNumber = document.getElementById(recId+'_DLN_Input').getElementsByTagName("input")[0].value;
        var dob = document.getElementById(recId+'_DOB_Input').getElementsByTagName("input")[0].value;
        
        var prevLName = document.getElementById(recId+'_Lname_Input').getElementsByTagName("input")[0].getAttribute('prevValue');
        var prevLicenceNumber = document.getElementById(recId+'_DLN_Input').getElementsByTagName("input")[0].getAttribute('prevValue');
        var prevDob = document.getElementById(recId+'_DOB_Input').getElementsByTagName("input")[0].getAttribute('prevValue');
        console.log('Lname: '+lName + '-----' + prevLName);
        console.log('Licence Number: '+drivingLicenceNumber + '-----' + prevLicenceNumber);
        console.log('DOB: '+dob + '-----' + prevDob);
        
        var valuesChanged = false;
        if(lName != prevLName) valuesChanged = true;
        if(drivingLicenceNumber != prevLicenceNumber) valuesChanged = true;
        if(dob != prevDob) valuesChanged = true;
        if(valuesChanged == false) {
            helper.toggleDriverEdit(component, event, recId);
            helper.hideSpinner(component, event);
            return;
        }
        
        var action = component.get("c.dvdDriverRecordUpdate");
        
        action.setParams({
            "recordId": recId,
            "lName": lName,
            "licenceNumber": drivingLicenceNumber,
            "dob": dob
        });
        
        console.log(action);
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var dvdDriverEntities = component.get("v.dvdDriversList");
                var dvdDriverEntitiesMap = component.get("v.dvdDriversMap");
                var driverItemToUpdate = dvdDriverEntitiesMap[recId];
                var driverItemToUpdateIndex = dvdDriverEntities.indexOf(driverItemToUpdate);
                //dvdDriverEntities.splice(driverItemToUpdateIndex, 1);
                driverItemToUpdate["Last_Name__c"] = lName;
                driverItemToUpdate["Drivers_Licence_Number__c"] = drivingLicenceNumber;
                driverItemToUpdate["Date_of_Birth__c"] = dob;
                driverItemToUpdate["Licence_Check__c"] = "None";
                driverItemToUpdate["Criminal_Check__c"] = "None";
                driverItemToUpdate["Serious_Driving_Offence__c"] = "None";
                driverItemToUpdate["P2P_Offence__c"] = "None";
                driverItemToUpdate["Last_DVD_Check_date__c"] = "";
                //dvdDriverEntities.push(driverItemToUpdate);
                dvdDriverEntitiesMap[recId] = driverItemToUpdate;dvdDriverEntities.splice(driverItemToUpdateIndex, 0, driverItemToUpdate);
                dvdDriverEntitiesMap[recId] = driverItemToUpdate;
                
                document.getElementById(recId+'_Lname_Output').innerHTML = lName;
                document.getElementById(recId+'_DLN_Output').innerHTML = drivingLicenceNumber;
                document.getElementById(recId+'_DOB_Output').innerHTML = dob;
                document.getElementById(recId+'_LC_Output').innerHTML = "";
                document.getElementById(recId+'_DVDCD_Output').innerHTML = "";
                
                //var currentSortId = component.get("v.sortDriverField");
                //component.set("v.sortDriverField", "");
                
                //helper.sortDriverBy(component, currentSortId, dvdDriverEntities);
                
                helper.toggleDriverEdit(component, event, recId);
                var resultsToast = $A.get("e.force:showToast");
                
                resultsToast.setParams({
                    "title": "Success",
                    "message": "Record updated successfully.",
                    "type": "success"
                });
                
                resultsToast.fire();
            }
            else {
                
                var resultsToast = $A.get("e.force:showToast");
                
                resultsToast.setParams({
                    "title": "Failure",
                    "message": "Record failed to update. Please ensure date format is dd/mm/yyyy",
                    "type": "error"
                });
                
                resultsToast.fire();
            }
            helper.hideSpinner(component, event);
            
        });
        
        $A.enqueueAction(action);
        
    },
    editVehicleDVDRecord: function(component, event, helper) {
        
        var recId;
        
        if(event.currentTarget == undefined)
         recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-RecId");
        else
         recId = event.currentTarget.getAttribute("data-RecId");
        
        console.log('Record to edit: '+recId);
        
        var pnInputText = document.getElementById(recId+'_PN_Output').innerHTML;
        var ptInputText = document.getElementById(recId+'_PT_Output').innerHTML;
        var vinInputText = document.getElementById(recId+'_VIN_Output').innerHTML;
        
        var pnInput = document.getElementById(recId+'_PN_Input');
        pnInput.innerHTML = "<input id='" + recId + "platenumber' maxlength='20' class='input uiInput uiInputText uiInput--default uiInput--input' type='text' prevValue='"+pnInputText+"' value='"+pnInputText+"'  />";
        var ptInput = document.getElementById(recId+'_PT_Input');
        ptInput.innerHTML = "<input id='" + recId + "platetype' maxlength='1' class='input uiInput uiInputText uiInput--default uiInput--input' type='text' prevValue='"+ptInputText+"' value='"+ptInputText+"'  />";
        var vinInput = document.getElementById(recId+'_VIN_Input');
        vinInput.innerHTML = "<input id='" + recId + "vin' maxlength='4' class='input uiInput uiInputText uiInput--default uiInput--input' type='text' prevValue='"+vinInputText+"' value='"+vinInputText+"' />";
        
        
        helper.toggleVehicleEdit(component, event, recId);				
    },
    updateVehicleDVDRecord: function(component, event, helper) {
        
        helper.showSpinner(component, event);
        
        var recId;
        
        if(event.currentTarget == undefined)
         recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-RecId");
        else
         recId = event.currentTarget.getAttribute("data-RecId");
        
        console.log('Record to edit: '+recId);
        
        var plateNumber = document.getElementById(recId+'_PN_Input').getElementsByTagName("input")[0].value;
        var plateType = document.getElementById(recId+'_PT_Input').getElementsByTagName("input")[0].value;
        var vin = document.getElementById(recId+'_VIN_Input').getElementsByTagName("input")[0].value;
        
        var prevPlateNumber = document.getElementById(recId+'_PN_Input').getElementsByTagName("input")[0].getAttribute('prevValue');
        var prevPlateType = document.getElementById(recId+'_PT_Input').getElementsByTagName("input")[0].getAttribute('prevValue');
        var prevVin = document.getElementById(recId+'_VIN_Input').getElementsByTagName("input")[0].getAttribute('prevValue');
        
        var valuesChanged = false;
        if(prevPlateNumber != plateNumber) valuesChanged = true;
        if(prevPlateType != plateType) valuesChanged = true;
        if(prevVin != vin) valuesChanged = true;
        if(valuesChanged == false) {
            helper.toggleVehicleEdit(component, event, recId);
            helper.hideSpinner(component, event);
            return;
        }
        
        console.log('Plate Number: '+plateNumber + '----' + prevPlateNumber);
        console.log('Plate Type: '+plateType + '-----' + prevPlateType);
        console.log('VIN: '+vin + '-----' + prevVin);
        
        var action = component.get("c.dvdVehicleRecordUpdate");
        
        action.setParams({
            "recordId": recId,
            "plateNumber": plateNumber,
            "plateType": plateType,
            "vin": vin
        });
        
        console.log(action);
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var dvdVehicleEntities = component.get("v.dvdVehiclesList");
                var dvdVehicleEntitiesMap = component.get("v.dvdVehiclesMap");
                var vehicleItemToUpdate = dvdVehicleEntitiesMap[recId];
                var vehicleItemToUpdateIndex = dvdVehicleEntities.indexOf(vehicleItemToUpdate);
                //dvdVehicleEntities.splice(vehicleItemToUpdateIndex, 1);
                vehicleItemToUpdate["Plate_Number__c"] = plateNumber;
                vehicleItemToUpdate["PLate_Type__c"] = plateType;
                vehicleItemToUpdate["VIN_Number_or_Chassis_Number__c"] = vin;
                vehicleItemToUpdate["Vehicle_Check__c"] = "None";
                vehicleItemToUpdate["Last_DVD_Check_date__c"] = "";
                
                dvdVehicleEntities.splice(vehicleItemToUpdateIndex, 0, vehicleItemToUpdate);
                //dvdVehicleEntities.push(vehicleItemToUpdate);
                dvdVehicleEntitiesMap[recId] = vehicleItemToUpdate;
                
                document.getElementById(recId+'_PN_Output').innerHTML = plateNumber;
                document.getElementById(recId+'_PT_Output').innerHTML = plateType;   
                document.getElementById(recId+'_VIN_Output').innerHTML = vin;
                document.getElementById(recId+'_VC_Output').innerHTML = "";
                document.getElementById(recId+'_DVDCD_Output').innerHTML = "";
                
                //var currentSortId = component.get("v.sortVehicleField");
                //component.set("v.sortVehicleField", "");
                
                //helper.sortVehicleBy(component, currentSortId, dvdVehicleEntities);
                
                helper.toggleVehicleEdit(component, event, recId);
                
                var resultsToast = $A.get("e.force:showToast");
                
                resultsToast.setParams({
                    "title": "Success",
                    "message": "Record updated successfully.",
                    "type": "success"
                });
                
                resultsToast.fire();
            }
            else {
                
                var resultsToast = $A.get("e.force:showToast");
                
                resultsToast.setParams({
                    "title": "Failure",
                    "message": "Record failed to update.",
                    "type": "error"
                });
                
                resultsToast.fire();
            }
            
            helper.hideSpinner(component, event);
        });
        
        $A.enqueueAction(action);
        
    },
    handleFleetEntityCreate : function(component, event, helper) {
        
        console.log('Entity Create Event');
        var recordType = event.getParam('fleetRecordType');
        var status = event.getParam('status');
        console.log('recordType|status = ' + recordType + '|' + status);
        if(status == 'Success'){
            if(recordType == 'Driver') {
                //refresh all drivers' list & set back focus to 'All' Tab
                console.log("In call helper");
                helper.loadDrivers(component, event);
            }else if(recordType == 'Vehicle'){
                //refresh all vehicles' list & set back focus to 'All' Tab
                helper.loadVehicles(component, event);
            }
        }
    }, 
    openFleetDetail: function(component,event,helper){
        
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.fleet_id;
        window.open("/s/dvd-query/related/" + recId + "/DVD_Queries__r");
    },    
    searchDriver : function(component, event, helper){
        
        if((event.currentTarget != undefined && event.currentTarget.id == "driverSearchIcon") 
            || event.getParam('keyCode') === 13) {
            
            var tab1 = component.find('allVehicles__itemtab');
            var tab2 = component.find('redVehicles__itemtab');
            var tab3 = component.find('whiteVehicles__itemtab');
            
            var recordsToSearch = component.get("v.dvdListBeforeSearch");
            var matchedRecordsMap = {};
            var matchedRecordsList = [];
            
            var driverSearchTerm = component.find("driverSearch").get("v.value");
            helper.showSpinner(component, event);
            if(driverSearchTerm != '') {
                
                var lastNameSearchResult = JSON.search(recordsToSearch, '//*[contains(Last_Name__c, "'+driverSearchTerm+'")]');
                console.log(lastNameSearchResult);
                
                if(lastNameSearchResult.length > 0)
                    matchedRecordsList = matchedRecordsList.concat(lastNameSearchResult);
                
                console.log('Final Result'+matchedRecordsList.length);
                
                var dlSearchResult = JSON.search(recordsToSearch, '//*[contains(Drivers_Licence_Number__c, "'+driverSearchTerm+'")]');
                console.log(dlSearchResult);
                if(dlSearchResult.length > 0)
                    matchedRecordsList = matchedRecordsList.concat(dlSearchResult);
                
                console.log(matchedRecordsList);  
                
                for(i=0;i<matchedRecordsList.length;i++)
                    matchedRecordsMap[matchedRecordsList[i].Id] = matchedRecordsList[i];
                
                matchedRecordsList = [];
                
                for(key in matchedRecordsMap)
                    matchedRecordsList.push(matchedRecordsMap[key]); 
                
                //component.set("v.dvdDriversList", matchedRecordsList);
                var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
                
                //number of records less than on scroll threshold, so load all
                if(matchedRecordsList.length < recordCountToLoadOnScroll) {
                 
                 component.set('v.dvdDriversList', matchedRecordsList);
                 helper.renderDriverTable(component, matchedRecordsList);
                 component.set('v.dvdFullScrollList', matchedRecordsList);
                }
                else {
                    
                 component.set('v.dvdFullScrollList', matchedRecordsList);
                 var records = matchedRecordsList.slice();
                 var recordSubsetToLoad = records.splice(0, recordCountToLoadOnScroll);
                 component.set('v.dvdDriversList', recordSubsetToLoad);
                 helper.renderDriverTable(component, recordSubsetToLoad);
                }	
                
            } else {                
                
                var records = component.get('v.dvdListBeforeSearch');
                
                var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
                
                //number of records less than on scroll threshold, so load all
                if(records.length < recordCountToLoadOnScroll) {
                    
                 component.set('v.dvdDriversList', records);
                 helper.renderDriverTable(component, records);
                 component.set('v.dvdFullScrollList', records);
                }
                else {
                    
                 component.set('v.dvdFullScrollList', records);
                 var tempRecords = records.slice();
                 var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
                 component.set('v.dvdDriversList', recordSubsetToLoad);
                 helper.renderDriverTable(component, recordSubsetToLoad);
                }
                
                //component.set('v.dvdDriversList', component.get('v.dvdListBeforeSearch'));
            }
            helper.hideSpinner(component, event);
        }
        
    },
    searchVehicle : function(component, event, helper){
        
        if((event.currentTarget != undefined && event.currentTarget.id == "vehicleSearchIcon")
           || event.getParam('keyCode') === 13) {
            
            var recordsToSearch = component.get("v.dvdListBeforeSearch");
            var matchedRecordsMap = {};
            var matchedRecordsList = [];
            
            var vehicleSearchTerm = component.find("vehicleSearch").get("v.value");
            helper.showSpinner(component, event);
            if(vehicleSearchTerm != '') {
                
                var plateNumberSearchResult = JSON.search(recordsToSearch, '//*[contains(Plate_Number__c, "'+vehicleSearchTerm+'")]');
                console.log(plateNumberSearchResult);
                
                if(plateNumberSearchResult.length > 0)
                    matchedRecordsList = matchedRecordsList.concat(plateNumberSearchResult);
                
                console.log('Final Result'+matchedRecordsList.length);
                
                var plateTypeSearchResult = JSON.search(recordsToSearch, '//*[contains(Plate_Type__c, "'+vehicleSearchTerm+'")]');
                console.log(plateTypeSearchResult);
                if(plateTypeSearchResult.length > 0)
                    matchedRecordsList = matchedRecordsList.concat(plateTypeSearchResult);
                
                var vinSearchResult = JSON.search(recordsToSearch, '//*[contains(VIN_Number_or_Chassis_Number__c, "'+vehicleSearchTerm+'")]');
                console.log(vinSearchResult);
                if(vinSearchResult.length > 0)
                    matchedRecordsList = matchedRecordsList.concat(vinSearchResult);
                
                console.log(matchedRecordsList);  
                
                for(i=0;i<matchedRecordsList.length;i++)
                    matchedRecordsMap[matchedRecordsList[i].Id] = matchedRecordsList[i];
                
                matchedRecordsList = [];
                
                for(key in matchedRecordsMap)
                    matchedRecordsList.push(matchedRecordsMap[key]); 
                
                //component.set("v.dvdVehiclesList", matchedRecordsList);
                var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
                
                //number of records less than on scroll threshold, so load all
                if(matchedRecordsList.length < recordCountToLoadOnScroll) {
                    
                 component.set('v.dvdVehiclesList', matchedRecordsList);
                 helper.renderVehicleTable(component, matchedRecordsList);
                 component.set('v.dvdFullScrollList', matchedRecordsList);
                }
                else {
                    
                 component.set('v.dvdFullScrollList', matchedRecordsList);
                 var records = matchedRecordsList.slice();
                 var recordSubsetToLoad = records.splice(0, recordCountToLoadOnScroll);
                 component.set('v.dvdVehiclesList', recordSubsetToLoad);
                 helper.renderVehicleTable(component, recordSubsetToLoad);
                }
            } else {                
                
                var records = component.get('v.dvdListBeforeSearch');
                
                var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
                
                //number of records less than on scroll threshold, so load all
                if(records.length < recordCountToLoadOnScroll) {
                    
                 component.set('v.dvdVehiclesList', records);
                 helper.renderVehicleTable(component, records);
                 component.set('v.dvdFullScrollList', matchedRecordsList);
                }
                else {
                    
                 component.set('v.dvdFullScrollList', records);
                 var tempRecords = records.slice();
                 var recordSubsetToLoad = records.splice(0, recordCountToLoadOnScroll);
                 component.set('v.dvdVehiclesList', recordSubsetToLoad);
                 helper.renderVehicleTable(component, recordSubsetToLoad);
                }
                //component.set('v.dvdVehiclesList', component.get('v.dvdListBeforeSearch'));
            }
            helper.hideSpinner(component, event);
        }
        
    },
    handleSelectAll : function(component, event, helper) {
        
        console.log("In handle checkbox");
        
        var whichOne = event.getSource().getLocalId();
        
        var selectedIds = [];
        component.set("v.selectedDVDRecords", []);
        
        if(whichOne=="selectAllDrivers") {
            
            console.log(document.getElementsByClassName('allDrivers'));
            console.log(document.getElementsByClassName('allDrivers').length);
            console.log(document.getElementsByClassName('allDrivers')[0].checked);
            var val = document.getElementsByClassName('allDrivers')[0].checked;
            
            var dvdDriversList = component.get("v.dvdFullScrollList");
            
            for(var index = 0; index < dvdDriversList.length; index++) {
                
                if(document.getElementsByClassName(dvdDriversList[index].Id).length > 0)
                 document.getElementsByClassName(dvdDriversList[index].Id)[0].checked = val;
                
                //adding checked id to the set
                if(val)
                 selectedIds.push(dvdDriversList[index].Id);
            }
            
        } else if(whichOne=="selectAllVehicles") {
            
            console.log("whichOne: "+whichOne);
            
            console.log(document.getElementsByClassName('allVehicles'));
            console.log(document.getElementsByClassName('allVehicles').length);
            console.log(document.getElementsByClassName('allVehicles')[0].checked);
            var val = document.getElementsByClassName('allVehicles')[0].checked;
            
            var dvdVehiclesList = component.get("v.dvdFullScrollList");
            
            for(var index = 0; index < dvdVehiclesList.length; index++) {
                
                if(document.getElementsByClassName(dvdVehiclesList[index].Id).length > 0)
                  document.getElementsByClassName(dvdVehiclesList[index].Id)[0].checked = val;
                
                //adding checked id to the set
                if(val)
                 selectedIds.push(dvdVehiclesList[index].Id);
            }
            
        }
        
        console.log('Selected Length: '+selectedIds.length);
        
        component.set("v.selectedDVDRecords", selectedIds);        
    },
    handleSingleSelect: function(component, event, helper) {
        
        //var checkBoxState = event.getSource().getElement().checked;
        //var checkBoxId = event.getSource().getElement().value;
        
        var checkBoxState;
        var checkBoxId;
        
        if(event.srcElement == undefined) {
            
            checkBoxState = event.getParam('arguments')[1].currentTarget.checked;
            checkBoxId = event.getParam('arguments')[1].currentTarget.id;
        }
        else {
         
            checkBoxState = event.srcElement.checked;
            checkBoxId = event.srcElement.id;
        }
        
        var existingSelectedIds = component.get("v.selectedDVDRecords");
        
        if(checkBoxState) {
            
            //adding checked id to the set
            existingSelectedIds.push(checkBoxId);
        } else{
            
            //removing unchecked id from the set of ids
            existingSelectedIds.splice(existingSelectedIds.indexOf(checkBoxId) , 1);
        }
        
        component.set("v.selectedDVDRecords", existingSelectedIds);
    },
    handleDVDCheck: function(component, event, helper) {
        
        var selectedIds = component.get("v.selectedDVDRecords");
        
        console.log('Got Event: '+event);
        console.log('Selected Ids: '+selectedIds.length);
        
        var entityType = event.getParam("entityType");
        console.log(entityType);
        
        if(entityType == 'Driver'){
            console.log('Matched Driver  = ' + entityType);
            var action;
            
            action = component.get('c.runCheckSelectedDrivers');
            action.setParams({
                "ids": selectedIds
            });			
            
            console.log(action);
            action.setCallback(this, function(response){
                
                var state = response.getState();
                console.log('Submitted Check For Drivers...' + response);
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Your request has been submitted.",
                    "type": "success"
                });
                toastEvent.fire();
                var nav = component.get('v.currentGrid');
                nav = 'DVDLogs';
                component.set("v.currentGrid", nav);
                
                var navEvt = $A.get("e.c:ASPDashboardTabNavigationEvent");
                navEvt.setParams({"tabName" : "DVDLogs"});
                navEvt.fire();
            });
            console.log('Enqueueing Action  = ' + action);
            $A.enqueueAction(action);  
        }
        else {
            var val = document.getElementsByClassName('allVehicles')[0].checked;
            console.log('all checkbox selected: ' + val);
            console.log('Matched Vehicle  = ' + entityType);
            var action = component.get('c.runCheckSelectedVehicles');
            action.setParams({
                "ids": selectedIds
            });
            console.log(action);
            action.setCallback(this,function(response){
                console.log('Submitted Check For Vehicles...' + response);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Your request has been submitted.",
                    "type": "success"
                });
                toastEvent.fire();
                var nav = component.get('v.currentGrid');
                nav = 'DVDLogs';
                component.set("v.currentGrid", nav);
                
                var navEvt = $A.get("e.c:ASPDashboardTabNavigationEvent");
                navEvt.setParams({"tabName" : "DVDLogs"});
                navEvt.fire();
            });
            console.log('Enqueueing Action  = ' + action);
            $A.enqueueAction(action);          
        }
    },
    cancelDriverDVDRecordEdit: function(component, event, helper) {        
                
        var recId;
        
        if(event.currentTarget == undefined)
         recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-RecId");
        else
         recId = event.currentTarget.getAttribute("data-RecId");
        
        helper.toggleDriverEdit(component, event, recId);
    },
    cancelVehicleDVDRecordEdit: function(component, event, helper) {        
        
        var recId;
        
        if(event.currentTarget == undefined)
         recId = event.getParam('arguments')[1].currentTarget.getAttribute("data-RecId");
        else
         recId = event.currentTarget.getAttribute("data-RecId");
        
        helper.toggleVehicleEdit(component, event, recId);
    },
    
})