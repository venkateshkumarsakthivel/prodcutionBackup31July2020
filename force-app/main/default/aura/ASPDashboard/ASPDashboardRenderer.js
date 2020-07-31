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
                        
                        newRecordsToAppend = totalRecords.splice(parseInt(newRecordsOffset), parseInt(component.get("v.recordCountToLoadOnScroll")));
                        
                        console.log(newRecordsToAppend.length);
                        
                        console.log('Get By Class Name: ');
                        
                        console.log(document.getElementsByClassName('allDrivers'));
                        
                        //var val = document.getElementsByClassName('allDrivers')[0].checked;
                        var val = component.find('selectAllDrivers').get("v.value");
                        
                        var tableBodyToAppend = '';
                        
                        console.log('Checkbox: '+val);
                        
                        for(var i=0;i<newRecordsToAppend.length;i++) {
                            
                            var licenceCheckResult = 'Licence Check';
                            if(newRecordsToAppend[i].Licence_Check__c == 'Green'){
                                licenceCheckResult = 'No Issue';
                            } else if(newRecordsToAppend[i].Licence_Check__c == 'Red'){
                                licenceCheckResult = 'Issue';
                            } else if(newRecordsToAppend[i].Licence_Check__c == 'White'){
                                licenceCheckResult = 'Unknown';
                            } else {
                                licenceCheckResult = 'System Error';
                            }
                            
                            var tenureCheckResult = 'NSW Tenure Check';
                            if(newRecordsToAppend[i].NSW_Tenure_Check__c == 'Green'){
                                tenureCheckResult = 'No Issue';
                            } else if(newRecordsToAppend[i].NSW_Tenure_Check__c == 'Red'){
                                tenureCheckResult = 'Issue';
                            } else if(newRecordsToAppend[i].NSW_Tenure_Check__c == 'White'){
                                tenureCheckResult = 'Unknown';
                            } else {
                                tenureCheckResult = 'System Error';
                            }
                            
                            var sdoCheckResult = 'SDO Check';
                            if(newRecordsToAppend[i].Serious_Driving_Offence__c == 'Green'){
                                sdoCheckResult = 'No Issue';
                            } else if(newRecordsToAppend[i].Serious_Driving_Offence__c == 'Red'){
                                sdoCheckResult = 'Issue';
                            } else if(newRecordsToAppend[i].Serious_Driving_Offence__c == 'White'){
                                sdoCheckResult = 'Unknown';
                            } else {
                                sdoCheckResult = 'System Error';
                            }
                            
                            var ccCheckResult = 'CC Check';
                            if(newRecordsToAppend[i].Criminal_Check__c == 'Green'){
                                ccCheckResult = 'No Issue';
                            } else if(newRecordsToAppend[i].Criminal_Check__c == 'Red'){
                                ccCheckResult = 'Issue';
                            } else if(newRecordsToAppend[i].Criminal_Check__c == 'White'){
                                ccCheckResult = 'Unknown';
                            } else {
                                ccCheckResult = 'System Error';
                            }
                            
                            var p2pEligibilityResultFlag = 'White';
                            var p2pEligibilityHover = 'Unknown';
                            if(newRecordsToAppend[i].P2P_Eligibility__c == 'Pass'){
                                p2pEligibilityResultFlag = 'Green';
                                p2pEligibilityHover = 'No Issue';
                            } else if(newRecordsToAppend[i].P2P_Eligibility__c == 'Fail'){
                                p2pEligibilityResultFlag = 'Red';
                                p2pEligibilityHover = 'Issue';
                            } else if(newRecordsToAppend[i].P2P_Eligibility__c == 'Unknown'){
                                p2pEligibilityResultFlag = 'White';
                            } else {
                                p2pEligibilityResultFlag = 'White';
                            }
                            
                            var licenceNumber = newRecordsToAppend[i].Drivers_Licence_Number__c;
                            var licenceLength = licenceNumber.length;
                            var last2Char = licenceNumber.substr(licenceLength-2,licenceLength);
                            maskedLicence = (Array(licenceLength-2).join('x'||' ') + 'x').slice(-(licenceLength-2))+last2Char;
                            
                            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
                            
                            rowBody += '<td role="gridcell" style="width:4%;">'; 
                            rowBody += '<span class="slds-truncate slds-align--absolute-center" title="Select Record">';
                            
                            if(val){
                                if(newRecordsToAppend[i].DVD_Status__c != 'Requested') {
                                    rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink-'+driverScrollIndex+'" checked/>';   
                                }
                                else{
                                    rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink-'+driverScrollIndex+'" disabled="true"/>';
                                }
                            }
                            else{
                                if(newRecordsToAppend[i].DVD_Status__c != 'Requested') {
                                    rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink-'+driverScrollIndex+'"/>';
                                }
                                else{
                                    rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink-'+driverScrollIndex+'" disabled="true"/>';
                                }
                            }                            
                            
                            rowBody += '</span></td>';
                            
                            rowBody += '<td role="gridcell" style="width:8%;max-width: 84px;word-wrap: break-word;white-space: pre-wrap;">';
                            rowBody += '<div class="slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_Lname_Output">';
                            rowBody += newRecordsToAppend[i].Last_Name__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_Lname_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:4%;">';
                            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_DLN_Output">';
                            rowBody += maskedLicence;//newRecordsToAppend[i].Drivers_Licence_Number__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_DLN_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:4%;">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_DOB_Output">';
                            rowBody += newRecordsToAppend[i].Date_of_Birth__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_DOB_Input">';  
                            rowBody += '</div></td>';
                            
                            if(component.get('v.ShowLicenceEligibility') == false){
                                rowBody += '<td role="gridcell" style="width:10%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + licenceCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_LC_Output">';
                                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Licence_Check__c+'" style="';
                                
                                if(newRecordsToAppend[i].Licence_Check__c != 'None')
                                    rowBody += 'display:block;"';
                                else
                                    rowBody += 'display:none;"';
                                
                                rowBody += '></img>';
                                rowBody += '</div></td>';
                            }else{
                                rowBody += '<td role="gridcell" style="width:10%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                                rowBody += '</div></td>';
                            }
                           	 					
                            if(component.get('v.hideTenureCheck') == false){
                                var imgIcon = 'Unknown';
                                if(newRecordsToAppend[i].NSW_Tenure_Check__c != undefined){
                                    imgIcon = newRecordsToAppend[i].NSW_Tenure_Check__c;
                                }
                                rowBody += '<td role="gridcell" style="width:10%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + tenureCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Tenure_Output">';
                                rowBody += '<img src="/industryportal/resource/'+ imgIcon +'" style="';
                                
                                if(newRecordsToAppend[i].NSW_Tenure_Check__c != 'None')
                                    rowBody += 'display:block;"';
                                else
                                    rowBody += 'display:none;"';
                                
                                rowBody += '></img>';
                                rowBody += '</div></td>';
                            }else{
                                rowBody += '<td role="gridcell" style="width:10%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                                rowBody += '</div></td>';
                            }
                            
                            if(component.get('v.ShowSeriousDrivingOffences') == false){				
                                rowBody += '<td role="gridcell" style="width:10%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + sdoCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_SDO_Output">';
                                rowBody += '<img src="/industryportal/resource/'+ newRecordsToAppend[i].Serious_Driving_Offence__c +'" style="';
                                
                                console.log('sdo: '+newRecordsToAppend[i].Serious_Driving_Offence__c);
                                if(newRecordsToAppend[i].Serious_Driving_Offence__c != 'None')
                                    rowBody += 'display:block;"';
                                else
                                    rowBody += 'display:none;"';
                                
                                rowBody += '></img>';
                                rowBody += '</div></td>';
                            }else{
                                rowBody += '<td role="gridcell" style="width:10%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                                rowBody += '</div></td>';
                            }
                            
                            var p2pEligibilityResultFlag = 'White';
                            var p2pEligibilityHover = 'Unknown';
                            if(newRecordsToAppend[i].P2P_Eligibility__c == 'Pass'){
                                p2pEligibilityResultFlag = 'Green';
                                p2pEligibilityHover = 'No Issue';
                            } else if(newRecordsToAppend[i].P2P_Eligibility__c == 'Fail'){
                                p2pEligibilityResultFlag = 'Red';
                                p2pEligibilityHover = 'Issue';
                            } else if(newRecordsToAppend[i].P2P_Eligibility__c == 'Unknown'){
                                p2pEligibilityResultFlag = 'White';
                            } else {
                                p2pEligibilityResultFlag = 'White';
                            }
                            
                            if(component.get('v.ShowP2pEligibility') == false){
                                var p2pstyle = 'display:none;';
                                if(newRecordsToAppend[i].P2P_Eligibility__c != 'None')
                                    p2pstyle = 'display:block;';
                                
                                
                                rowBody += '<td role="gridcell" style="width:13%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + p2pEligibilityHover + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_P2E_Output">';
                                rowBody += '<img src="/industryportal/resource/'+ p2pEligibilityResultFlag +'" style="' + p2pstyle + '"></img>';
                                rowBody += '</div></td>';
                            }else{
                                rowBody += '<td role="gridcell" style="width:13%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                                rowBody += '</div></td>';  
                            }
                            
                            
                            if(component.get('v.ShowCriminalCharge') == false){
                                rowBody += '<td role="gridcell" style="width:10%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + ccCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_CC_Output">';
                                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Criminal_Check__c+'" style="';
                                
                                if(newRecordsToAppend[i].Criminal_Check__c != 'None')
                                    rowBody += 'display:block;"';
                                else
                                    rowBody += 'display:none;"';
                                
                                rowBody += '></img>';
                                rowBody += '</div></td>';
                            }else{
                                rowBody += '<td role="gridcell" style="width:10%;" class="tabCol">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                                rowBody += '</div></td>';
                            }
                           // PT code added								
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                //console.log('Hello + ' newRecordsToAppend[i].PTCode_Active_Start_Date__c); 
                                rowBody += '<td role="gridcell" style="width:10%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="PT Code" id="'+newRecordsToAppend[i].Id+'_PTCode_Output">';
                                rowBody += 'In Progress';
                                rowBody += '</div></td>';
                            }
                            else {
                                //console.log('Hello2 + ' newRecordsToAppend[i].PTCode_Active_Start_Date__c);  
                                rowBody += '<td role="gridcell" style="width:10%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="PT Code" id="'+newRecordsToAppend[i].Id+'_PTCode_Output">';
                               rowBody += newRecordsToAppend[i].PTCode_Active_Start_Date__c;
                                 //rowBody += 'In Progress';
                                rowBody += '</div></td>'; 
                            }		
                            // Pt code end 	 
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                
                                rowBody += '<td role="gridcell" style="width:9%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                                rowBody += 'In Progress';
                                rowBody += '</div></td>';
                            }
                            else {
                                
                                rowBody += '<td role="gridcell" style="width:9%;">';
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
                            /*
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
                            */
                            
                            rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark toggleDisplay driverCancelLink-'+driverScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Cancel" title="Cancel">';  
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-times"></i>';
                            rowBody += '</span></td></tr>';
                            
                            tableBodyToAppend += rowBody;
                        }
                        
                        $('#driverTableBody').append(tableBodyToAppend);
                        
                        $('.driverEditLink-'+driverScrollIndex).click(function (ev) { component.editDriver(component, ev, helper); });
                        $('.driverUpdateLink-'+driverScrollIndex).click(function (ev) { component.updateDriver(component, ev, helper); });
                        //$('.driverDeleteLink-'+driverScrollIndex).click(function (ev) { component.deleteDriver(component, ev, helper); });
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
                        
                        newRecordsToAppend = totalRecords.splice(parseInt(newRecordsOffset), parseInt(component.get("v.recordCountToLoadOnScroll")));
                        
                        //var val = document.getElementsByClassName('allVehicles')[0].checked;
                        
                        var val = component.find('selectAllVehicles').get("v.value");
                        
                        var colWidth = component.get("v.vehTableColWidth");
                        
                        var tableBodyToAppend = '';
                        
                        for(var i=0;i<newRecordsToAppend.length;i++) {
                            
                            var vehicleCheckResult = 'Licence Check';
                            if(newRecordsToAppend[i].Vehicle_Check__c == 'Green'){
                                vehicleCheckResult = 'No Issue';
                            } else if(newRecordsToAppend[i].Vehicle_Check__c == 'Red'){
                                vehicleCheckResult = 'Issue';
                            } else if(newRecordsToAppend[i].Vehicle_Check__c == 'White'){
                                vehicleCheckResult = 'Unknown';
                            } else {
                                vehicleCheckResult = 'System Error';
                            }
                            //Taxi Licence result
                            var taxiLicenceCheckResult = 'Taxi Licence Status';
                            if(newRecordsToAppend[i].Taxi_Licence_Status__c == 'Green'){
                                taxiLicenceCheckResult = 'No Issue';
                            } else if(newRecordsToAppend[i].Taxi_Licence_Status__c == 'Red'){
                                taxiLicenceCheckResult = 'Issue';
                            } else if(newRecordsToAppend[i].Taxi_Licence_Status__c == 'White'){
                                taxiLicenceCheckResult = 'Unknown';
                            } else {
                                taxiLicenceCheckResult = 'None';
                            }
                            
                            var safetyCheckResult = 'Safety Check Status';
                            if(newRecordsToAppend[i].Last_AIS_Inspection_Date_Check__c === 'Green'){
                                safetyCheckResult = 'No Issue';
                            } else if(newRecordsToAppend[i].Last_AIS_Inspection_Date_Check__c === 'Red'){
                                safetyCheckResult = 'Issue';
                            } else if(newRecordsToAppend[i].Last_AIS_Inspection_Date_Check__c === 'White'){
                                safetyCheckResult = 'Unknown';
                            } else {
                                safetyCheckResult = 'None';
                            }
                            
                            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
                            
                            rowBody += '<td scope="col" role="gridcell" style="width:' + colWidth.vehSelect +'">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Select Record">';
                            
                            if(val){
                                if(newRecordsToAppend[i].DVD_Status__c != 'Requested') {
                                    rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink-'+vehicleScrollIndex+'" checked/>';   
                                }
                                else{
                                    rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink-'+vehicleScrollIndex+'" disabled="true"/>';
                                }
                            }
                            else{
                                if(newRecordsToAppend[i].DVD_Status__c != 'Requested') {
                                    rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink-'+vehicleScrollIndex+'"/>';
                                }
                                else{
                                    rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink-'+vehicleScrollIndex+'" disabled="true"/>';
                                }
                            }
                            rowBody += '</div></td>';
                            
                            rowBody += '<td scope="col" role="gridcell" style="width:' + colWidth.plateNumber +'">';
                            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_PN_Output">';
                            rowBody += newRecordsToAppend[i].Plate_Number__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_PN_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:' + colWidth.plateType +'">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_PT_Output">';
                            rowBody += newRecordsToAppend[i].Plate_Type__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_PT_Input">';  
                            rowBody += '</div></td>';
                            
                            rowBody += '<td role="gridcell" style="width:' + colWidth.vinChasis +'">';
                            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_VIN_Output">';
                            rowBody += newRecordsToAppend[i].VIN_Number_or_Chassis_Number__c;
                            rowBody += '</div>';
                            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_VIN_Input">';  
                            rowBody += '</div></td>';
                            
                            if(component.get('v.ShowVehicleCheck') == false){
                                rowBody += '<td role="gridcell" style="width:' + colWidth.vehicleCheck +'">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center vehicle-dvd-check-output" title="' + vehicleCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_VC_Output">';
                                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Vehicle_Check__c+'" style="';
                                
                                if(newRecordsToAppend[i].Vehicle_Check__c != 'None')
                                    rowBody += 'display:block;"';
                                else
                                    rowBody += 'display:none;"';
                                
                                rowBody += '></img>';
                                rowBody += '</div></td>';
                            }else{
                                rowBody += '<td role="gridcell" style="width:' + colWidth.vehicleCheck +'">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                                rowBody += '</div></td>';
                            }
                            //Taxi Licence Status Start
                            if(component.get("v.taxiLicenceCheck")){
                                rowBody += '<td role="gridcell" style="width:' + colWidth.taxilicCheck +'">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center taxilic-dvd-check-output" title="' + taxiLicenceCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_TLC_Output">';
                                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Taxi_Licence_Status__c+'" style="';
                                
                                if(newRecordsToAppend[i].Taxi_Licence_Status__c != 'None')
                                    rowBody += 'display:block;"';
                                else
                                    rowBody += 'display:none;"';
                                
                                rowBody += '></img>';
                                rowBody += '</div></td>';
                            }
                            //////End
                            
                            var inspectionDateStyle = '';
                            if(newRecordsToAppend[i].Last_AIS_Inspection_Date_Check__c == 'Red'){
                                inspectionDateStyle = 'style="color:red"';
                            }
                            
                            if(component.get('v.hideInspectionDateCheck') == false){
                                rowBody += '<td role="gridcell" style="width:' + colWidth.safetyCheck +'">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center vehicle-dvd-check-output" title="' + safetyCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_SafetyCheck_Output">';
                                rowBody += '<span ' + inspectionDateStyle + '>' + newRecordsToAppend[i].Last_AIS_Inspection_Date__c + '</span>';
                                rowBody += '</div></td>';
                            }else{
                                rowBody += '<td role="gridcell" style="width:' + colWidth.safetyCheck +'">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                                rowBody += '</div></td>';
                            }
                            
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                
                                rowBody += '<td role="gridcell" style="width:' + colWidth.dvdStatus +'">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                                rowBody += 'In Progress';
                                rowBody += '</div></td>';
                            }
                            else {
                                
                                rowBody += '<td role="gridcell" style="width:' + colWidth.dvdStatus +'">';
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
                            /*
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
                            */
                            
                            rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark toggleDisplay vehicleCancelLink-'+vehicleScrollIndex+'" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Cancel" title="Cancel">';  
                            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-times"></i>';
                            rowBody += '</span></td></tr>';
                            
                            tableBodyToAppend += rowBody;
                        }
                        
                        $('#vehicleTableBody').append(tableBodyToAppend);
                        
                        $('.vehicleEditLink-'+vehicleScrollIndex).click(function (ev) { component.editVehicle(component, ev, helper); });
                        $('.vehicleUpdateLink-'+vehicleScrollIndex).click(function (ev) { component.updateVehicle(component, ev, helper); });
                        //$('.vehicleDeleteLink-'+vehicleScrollIndex).click(function (ev) { component.deleteVehicle(component, ev, helper); });
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