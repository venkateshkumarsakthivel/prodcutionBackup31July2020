({
    afterRender: function (component, helper) {
        
        this.superAfterRender();
    },
    rerender: function(component, helper) {
        
        this.superRerender();
        
        var didDriverScroll = false;
        var driverScrollIndex = component.get("v.driverScrollIndex");
        var driverScrollContainer = document.getElementById('driverTableScrollContainer');
        
        if(driverScrollContainer != null) {
            
            driverScrollContainer.onscroll = function() {
                
                console.log('Scrolling');
                didDriverScroll = true;
                //var recordCountToLoadOnScroll = component.get("v.recordCountToLoadOnScroll");
            };
            
            // periodically attach the scroll event listener
            // so that we aren't taking action for all events
            var driverScrollCheckIntervalId = window.setInterval($A.getCallback( function() {
                
                // since this function is called asynchronously outside the component's lifecycle
                // we need to check if the component still exists before trying to do anything else
                if(didDriverScroll && component.isValid()) {
                    
                    didDriverScroll = false;
                    console.log('called');
                    
                    console.log($('#driverTableScrollContainer').scrollTop());
                    console.log(driverScrollContainer.scrollHeight);
                    console.log($('#driverTableScrollContainer').outerHeight(true));
                    
                    // adapted from stackoverflow to detect when user has scrolled sufficiently to end of document
                    // http://stackoverflow.com/questions/4841585/alternatives-to-jquery-endless-scrolling
                    if($('#driverTableScrollContainer').scrollTop() >= driverScrollContainer.scrollHeight - $('#driverTableScrollContainer').outerHeight(true) - 100) {
                        
                        console.log('In If');
                        
                        driverScrollIndex = parseInt(driverScrollIndex+1);
                        component.set("v.driverScrollIndex", driverScrollIndex);
                        
                        console.log(driverScrollIndex);
                        
                        var currentRecords = component.get("v.dvdDriversList");
                        //var totalRecords = component.get("v.dvdFullScrollList");
                        
                        var totalRecords = $.merge([], component.get("v.dvdFullScrollList"));
                        
                        var newRecordsToAppend = [];
                        
                        var newRecordsOffset = parseInt((driverScrollIndex - 1) * component.get("v.recordCountToLoadOnScroll"));
                        
                        console.log('New Record Offset: '+newRecordsOffset);
                        
                        console.log('Total Record Count: '+totalRecords.length);
                        
                        console.log('Full Scroll List: '+component.get("v.dvdFullScrollList").length);
                        
                        console.log(totalRecords.length - (newRecordsOffset+1));
                        
                        console.log('Param 1: '+parseInt(newRecordsOffset+1));
                        console.log('Param 2: '+parseInt(component.get("v.recordCountToLoadOnScroll")));
                        
                        newRecordsToAppend = totalRecords.splice(parseInt(newRecordsOffset+1), parseInt(component.get("v.recordCountToLoadOnScroll")));
                        
                        console.log(newRecordsToAppend.length);
                        
                        var val = document.getElementsByClassName('allDrivers')[0].checked;
                        var tableBodyToAppend = '';
                        
                        for(var i=0;i<newRecordsToAppend.length;i++) {
                            
                            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
                            
                            rowBody += '<td role="gridcell" style="width:5%;">'; 
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Select Record">';
                            
                            if(val)
                                rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink-'+driverScrollIndex+'" checked/>';
                            else
                                rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink-'+driverScrollIndex+'"/>';
                            
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:13%;">';
                            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_Lname_Output">';
                            rowBody += newRecordsToAppend[i].Last_Name__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_Lname_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:13%;">';
                            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_DLN_Output">';
                            rowBody += newRecordsToAppend[i].Drivers_Licence_Number__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_DLN_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:13%;">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_DOB_Output">';
                            rowBody += newRecordsToAppend[i].Date_of_Birth__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_DOB_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" class="tabCol">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Licence Check" data-fleet_id="'+newRecordsToAppend[i].Id+'" onclick="{!c.openFleetDetail}" id="'+newRecordsToAppend[i].Id+'_LC_Output" style="cursor:pointer;">';
                            rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Licence_Check__c+'" style="';
                            
                            if(newRecordsToAppend[i].Licence_Check__c != 'None')
                                rowBody += 'display:block;"';
                            else
                                rowBody += 'display:none;"';
                            
                            rowBody += '></img>';
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" class="tabCol">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" class="tabCol">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" class="tabCol">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                            rowBody += '</div></td>';
                            
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                
                                rowBody += '<td role="gridcell" style="width:13%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                                rowBody += 'In Progress';
                                rowBody += '</div></td>';
                            }
                            else {
                                
                                rowBody += '<td role="gridcell" style="width:13%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                                rowBody += newRecordsToAppend[i].Last_DVD_Check_date__c;
                                rowBody += '</div></td>'; 
                            }
                            
                            rowBody += '<td role="gridcell" style="padding:0px">';
                            
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                
                                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil fa-disabled"></i>';
                                rowBody += '</span>';
                            }
                            else {
                                
                                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark driverEditLink-'+driverScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil"></i>';
                                rowBody += '</span>';
                            }
                            
                            rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:5px;" class="slds-truncate questionmark toggleDisplay driverUpdateLink-'+driverScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Save" title="Save">';
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-check"></i>';
                            rowBody += '</span></td>';
                            
                            rowBody += '<td role="gridcell" style="padding:0px">';
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                
                                rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Delete" title="Delete">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-trash-o fa-disabled"></i>';
                                rowBody += '<br/></span>';
                            }
                            else {
                                
                                rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark driverDeleteLink-'+driverScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Delete" title="Delete">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-trash-o"></i>';
                                rowBody += '<br/></span>';
                            }
                            
                            rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark toggleDisplay driverCancelLink-'+driverScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Cancel" title="Cancel">';  
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-times"></i>';
                            rowBody += '</span></td></tr>';
                            
                            tableBodyToAppend += rowBody;
                        }
                        
                        $('#driverTableBody').append(tableBodyToAppend);
                        
                        $('.driverEditLink-'+driverScrollIndex).click(function (ev) { component.editDriver(component, ev, helper); });
                        $('.driverUpdateLink-'+driverScrollIndex).click(function (ev) { component.updateDriver(component, ev, helper); });
                        $('.driverDeleteLink-'+driverScrollIndex).click(function (ev) { component.deleteDriver(component, ev, helper); });
                        $('.driverCancelLink-'+driverScrollIndex).click(function (ev) { component.cancelDriver(component, ev, helper); });
                        $('.driverSelectLink-'+driverScrollIndex).change(function (ev) { component.selectDriver(component, ev, helper); });
                        
                    }
                    
                }
                
            }), 1000);
            
            component.set( 'v.driverScrollCheckIntervalId', driverScrollCheckIntervalId);
        }
        
        
        var didVehicleScroll = false;
        var vehicleScrollIndex = component.get("v.vehicleScrollIndex");
        var vehicleScrollContainer = document.getElementById('vehicleTableScrollContainer');
        
        if(vehicleScrollContainer != null) {
            
            vehicleScrollContainer.onscroll = function() {
                
                console.log('Scrolling');
                didVehicleScroll = true;
                //var recordCountToLoadOnScroll = component.get("v.recordCountToLoadOnScroll");
            };
            
            // periodically attach the scroll event listener
            // so that we aren't taking action for all events
            var vehicleScrollCheckIntervalId = window.setInterval($A.getCallback( function() {
                
                // since this function is called asynchronously outside the component's lifecycle
                // we need to check if the component still exists before trying to do anything else
                if(didVehicleScroll && component.isValid()) {
                    
                    didVehicleScroll = false;
                    console.log('called');
                    
                    console.log($('#vehicleTableScrollContainer').scrollTop());
                    console.log(vehicleScrollContainer.scrollHeight);
                    console.log($('#vehicleTableScrollContainer').outerHeight(true));
                    
                    // adapted from stackoverflow to detect when user has scrolled sufficiently to end of document
                    // http://stackoverflow.com/questions/4841585/alternatives-to-jquery-endless-scrolling
                    if($('#vehicleTableScrollContainer').scrollTop() >= vehicleScrollContainer.scrollHeight - $('#vehicleTableScrollContainer').outerHeight(true) - 100) {
                        
                        console.log('In If');
                        
                        vehicleScrollIndex = vehicleScrollIndex+1;
                        component.set("v.vehicleScrollIndex", vehicleScrollIndex);
                        
                        console.log(vehicleScrollIndex);
                        
                        var currentRecords = component.get("v.dvdVehiclesList");
                        //var totalRecords = component.get("v.dvdFullScrollList");
                        
                        var totalRecords = $.merge([], component.get("v.dvdFullScrollList"));
                        
                        var newRecordsToAppend;
                        
                        var newRecordsOffset = parseInt((vehicleScrollIndex - 1) * component.get("v.recordCountToLoadOnScroll"));
                        
                        console.log('New Record Offset: '+newRecordsOffset);
                        
                        console.log('Total Record Count: '+totalRecords.length);
                        
                        console.log(totalRecords.length - (newRecordsOffset+1));
                        
                        console.log('Param 1: '+parseInt(newRecordsOffset+1));
                        console.log('Param 2: '+parseInt(component.get("v.recordCountToLoadOnScroll")));
                        
                        newRecordsToAppend = totalRecords.splice(parseInt(newRecordsOffset+1), parseInt(component.get("v.recordCountToLoadOnScroll")));
                        
                        var val = document.getElementsByClassName('allVehicles')[0].checked;
                        var tableBodyToAppend = '';
                        
                        for(var i=0;i<newRecordsToAppend.length;i++) {
                            
                            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
                            
                            rowBody += '<td scope="col" role="gridcell" style="width:6%;">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Select Record">';
                            
                            if(val)
                                rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink-'+vehicleScrollIndex+'" checked/>';
                            else
                                rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink-'+vehicleScrollIndex+'"/>';
                            
                            rowBody += '</div></td>';
                            
                            rowBody += '<td scope="col" role="gridcell" style="width:20%;">';
                            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_PN_Output">';
                            rowBody += newRecordsToAppend[i].Plate_Number__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_PN_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:18%;">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_PT_Output">';
                            rowBody += newRecordsToAppend[i].Plate_Type__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_PT_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:18%;">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_VIN_Output">';
                            rowBody += newRecordsToAppend[i].VIN_Number_or_Chassis_Number__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_VIN_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:15%;">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center vehicle-dvd-check-output" title="Licence Check" data-fleet_id="'+newRecordsToAppend[i].Id+'" onclick="{!c.openFleetDetail}" id="'+newRecordsToAppend[i].Id+'_VC_Output" style="cursor:pointer;">';
                            rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Vehicle_Check__c+'" style="';
                            
                            if(newRecordsToAppend[i].Vehicle_Check__c != 'None')
                                rowBody += 'display:block;"';
                            else
                                rowBody += 'display:none;"';
                            
                            rowBody += '></img>';
                            rowBody += '</div></td>';
                            
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                
                                rowBody += '<td role="gridcell" style="width:18%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                                rowBody += 'In Progress';
                                rowBody += '</div></td>';
                            }
                            else {
                                
                                rowBody += '<td role="gridcell" style="width:18%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                                rowBody += newRecordsToAppend[i].Last_DVD_Check_date__c;
                                rowBody += '</div></td>';  
                            }
                            
                            rowBody += '<td role="gridcell" style="padding:0px">';
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                
                                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil fa-disabled"></i>';
                                rowBody += '</span>';
                            }
                            else {
                                
                                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark vehicleEditLink-'+vehicleScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil"></i>';
                                rowBody += '</span>';
                            }
                            
                            rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:5px;" class="slds-truncate questionmark toggleDisplay vehicleUpdateLink-'+vehicleScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Save" title="Save">';
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-check"></i>';
                            rowBody += '</span></td>';
                            
                            rowBody += '<td role="gridcell" style="padding:0px">';
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                
                                rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Delete" title="Delete">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-trash-o fa-disabled"></i>';
                                rowBody += '<br/></span>';
                            }
                            else {
                                
                                rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark vehicleDeleteLink-'+vehicleScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Delete" title="Delete">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-trash-o"></i>';
                                rowBody += '<br/></span>';
                            }
                            rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark toggleDisplay vehicleCancelLink-'+vehicleScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Cancel" title="Cancel">';  
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-times"></i>';
                            rowBody += '</span></td></tr>';
                            
                            tableBodyToAppend += rowBody;
                        }
                        
                        $('#vehicleTableBody').append(tableBodyToAppend);
                        
                        $('.vehicleEditLink-'+vehicleScrollIndex).click(function (ev) { component.editVehicle(component, ev, helper); });
                        $('.vehicleUpdateLink-'+vehicleScrollIndex).click(function (ev) { component.updateVehicle(component, ev, helper); });
                        $('.vehicleDeleteLink-'+vehicleScrollIndex).click(function (ev) { component.deleteVehicle(component, ev, helper); });
                        $('.vehicleCancelLink-'+vehicleScrollIndex).click(function (ev) { component.cancelVehicle(component, ev, helper); });
                        $('.vehicleSelectLink-'+vehicleScrollIndex).change(function (ev) { component.selectVehicle(component, ev, helper); });
                        
                    }
                    
                }
                
            }), 1000);
            
            component.set( 'v.vehicleScrollCheckIntervalId', vehicleScrollCheckIntervalId);
        } 
    },
    unrender : function( component, helper ) {
        
        this.superUnrender();
        
        var driverScrollCheckIntervalId = component.get('v.driverScrollCheckIntervalId');
        if(!$A.util.isUndefinedOrNull(driverScrollCheckIntervalId)) {
            window.clearInterval(driverScrollCheckIntervalId);
        }
        
        var vehicleScrollCheckIntervalId = component.get('v.vehicleScrollCheckIntervalId');
        
        if(!$A.util.isUndefinedOrNull(vehicleScrollCheckIntervalId)) {
            window.clearInterval(vehicleScrollCheckIntervalId);
        }
        
    }
})