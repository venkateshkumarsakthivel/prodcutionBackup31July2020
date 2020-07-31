({
    loadDVDQueryLogs : function(component,event) {
        
        this.showSpinner(component, event);
        console.log('loadLogs Started');
        var action = component.get('c.getDVDQueryGroupLogs');
        action.setCallback(this,function(result){
            
            component.set('v.dvdQueryGroupList',result.getReturnValue());
            console.log('Loaded DVD Query Group Logs'); 
            this.hideSpinner(component, event);    
        });
        $A.enqueueAction(action);
    },
    getCurrentTime : function(component, event,recId ,runType){
        var action = component.get('c.getCurrentTime');
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === "SUCCESS") {
                var currentTime = result.getReturnValue();
                var fileName;
                if(dateTime != '' || dateTime != undefined){
                    var dateTime = currentTime.split('-');
                    var date = dateTime[0];
                    var time = dateTime[1];
                    
                    if(runType.includes("Vehicle")){
                        fileName = 'Vehicles logs on '+date+ '@'+time+'.csv'; 
                        this.exportDVDQueryGroup(component, event, recId, runType,fileName);
                    }
                    else if(runType.includes("Driver")){
                        fileName = 'Drivers logs on '+date+ '@'+time+'.csv'; 
                        this.exportDVDQueryGroup(component, event, recId, runType,fileName);
                    }
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    exportDVDQueryGroup: function(component, event, queryGroupId, type,NameOfFile) {
        console.log('Performing export of queries');
        var action = component.get('c.QueriesToExport');
        action.setParams({
            "recId" : queryGroupId,
            "dvdEntityType" : type
        });
        action.setCallback(this,function(result){
            console.log('Export results received');
            var dataToExport = result.getReturnValue();
            this.exportDVDRecords (component, event, type, dataToExport,NameOfFile);
            
            //this.hideSpinner(component, event);    
        });
        
        $A.enqueueAction(action);
        
    },
    
    exportDVDRecords : function(component, event, type, dataToExport,fileName){
        console.log("In ExportDVDLogs");
        var records = dataToExport;
        var data = [];
        var headerArray = [];
        var csvContentArray = [];
        var sno = 0;
        
        //Fill out the Header of CSV
        if(type.includes("Driver")){
            console.log("In Drivers");
           // console.log(records);
            
            headerArray.push('#');
            headerArray.push('NSW Driver Licence');
            if(component.get('v.ShowLicenceEligibility') == false)
                headerArray.push('Licence Eligibility');
           
            if(component.get('v.hideTenureCheck') == false)
                headerArray.push('NSW Licence Tenure');
			if(component.get('v.ShowSeriousDrivingOffences') == false)
                headerArray.push('Serious Driving Offences');
            if(component.get('v.ShowP2pEligibility') == false)
                headerArray.push('P2P Eligibility');
            if(component.get('v.ShowCriminalCharge') == false)
                headerArray.push('Criminal Charge');
            //PT code
             headerArray.push('PT Code Applied');
            
            headerArray.push('Last Checked');
            
            data.push(headerArray);
            console.log("In Drivers 2");
            
            for(var i=0;i < records.length;i++) {
                console.log("In Drivers: "+i);
                //Initialize the temperory array
                var tempArray = [];
                //use parseInt to perform math operation
                //tempArray.push("\r\n");
                sno = parseInt(sno) + parseInt(1);
                tempArray.push('"'+sno+'"');
                tempArray.push('"'+records[i].Drivers_Licence_Number__c+'"');
                
                if(component.get('v.ShowLicenceEligibility') == false){
                    tempArray.push('"'+this.getSignal(records[i].Traffic_Light_Indicator__c, 'Licence_Check')+'"');
                }
             
				
                if(component.get('v.hideTenureCheck') == false){
                    tempArray.push('"'+this.getSignal(records[i].NSW_Tenure_Check__c, 'Tenure_Check')+'"');
                }
				
                if(component.get('v.ShowSeriousDrivingOffences') == false){
                    tempArray.push('"'+this.getSignal(records[i].SDO_Check_Status__c, 'Driving_History_Check')+'"');
                }
                
                if(component.get('v.ShowP2pEligibility') == false){
                    if(records[i].P2P_Eligibility__c != undefined)
                        tempArray.push('"'+this.getSignal(records[i].P2P_Eligibility__c,'P2P_Eligibility')+'"');
                    else
                        tempArray.push('');
                }
                
                if(component.get('v.ShowCriminalCharge') == false){
                    tempArray.push('"'+this.getSignal(records[i].Criminal_Charge_Check_Status__c, 'Criminal_Check')+'"');
                }
                tempArray.push('"'+this.formatDate(records[i].PTCode_Active_Start_Date__c)+'"');
                //tempArray.push('"'+records[i].PTCode_Active_Start_Date__c+'"');
                tempArray.push('"'+this.formatDate(records[i].CreatedDate)+'"');
                data.push(tempArray);
            }
            
            console.log("In Drivers 3");
            
            for(var j=0;j<data.length;j++){
                
                var dataString = data[j].join(",");
                csvContentArray.push(dataString);
            }
            
            var csvContent = csvContentArray.join("\r\n");
            //var fileName = "Report_";
            
            //this will remove the blank-spaces from the title and replace it with an underscore
            fileName = fileName.replace(/ /g,":");   
            fileName += ".csv";
            
            //Initialize file format you want csv or xls
            var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
            if (navigator.msSaveBlob) { // IE 10+
                console.log('----------------if-----------');
                var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
                console.log('----------------if-----------'+blob);
                navigator.msSaveBlob(blob, fileName);
            }
            else{
                console.log('Else executed');
                var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
                var csvUrl = URL.createObjectURL(blob);
                var link = document.createElement("a");
                link.setAttribute('download',fileName);
                
                //To set the content of the file
                //link.href = uri;
                link.href = csvUrl;
                
                //set the visibility hidden so it will not effect on your web-layout
                link.style = "visibility:hidden";
                
                //this part will append the anchor tag and remove it after automatic click
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                
            }
        }
        else if(type.includes("Vehicle")){
            
            console.log("In Vehicles");
            
            headerArray.push('#');
            headerArray.push('Plate Number');
            if(component.get('v.ShowVehicleCheck') == false)
                headerArray.push('Vehicle Check');
            if(component.get("v.taxiLicenceCheck"))
                headerArray.push('Taxi Licence Status');
            if(component.get("v.hideInspectionDateCheck") == false)
                headerArray.push('Safety Check');
            headerArray.push('Checked Date');
            data.push(headerArray);
            //console.log(data);
            
            
            for(var i=0;i< records.length;i++){
                
                //Initialize the temperory array
                var tempArray = [];
                
                //use parseInt to perform math operation
                sno = parseInt(sno) + parseInt(1);
                tempArray.push('"'+sno+'"');
                tempArray.push('"'+records[i].Plate_Number__c+'"');
                
                if(component.get('v.ShowVehicleCheck') == false){
                    tempArray.push('"'+this.getSignal(records[i].Traffic_Light_Indicator__c, 'Vehicle_Check')+'"');
                }
				if(component.get("v.taxiLicenceCheck"))
                    tempArray.push('"'+this.getSignal(records[i].Taxi_Licence_Status__c, 'Taxi_Licence_Status')+'"'); 
                if(component.get("v.hideInspectionDateCheck") == false)
                    tempArray.push('"'+this.formatDate(records[i].Last_AIS_Inspection_Date__c)+'"');
                
                tempArray.push('"'+this.formatDate(records[i].CreatedDate)+'"');
                
                data.push(tempArray);
            }
            
            for(var j=0;j<data.length;j++){
                var dataString = data[j].join(",");
                csvContentArray.push(dataString);
            }
            
            var csvContent = csvContentArray.join("\r\n");
            //this will remove the blank-spaces from the title and replace it with an underscore
            fileName = fileName.replace(/ /g,":");   
            fileName += ".csv";
            
            //Initialize file format you want csv or xls
            var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
            if (navigator.msSaveBlob) { // IE 10+
                console.log('----------------if-----------');
                var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
                console.log('----------------if-----------'+blob);
                navigator.msSaveBlob(blob, fileName);
            }
            else{
                console.log('else executed');
                var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
                var csvUrl = URL.createObjectURL(blob);
                var link = document.createElement("a");
                link.setAttribute('download',fileName);
                
                //To set the content of the file
                //link.href = uri;
                link.href = csvUrl;
                
                //set the visibility hidden so it will not effect on your web-layout
                link.style = "visibility:hidden";
                
                //this part will append the anchor tag and remove it after automatic click
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                
            }
            
        }
    },
    formatDate : function(inputDate) {
        
        if(inputDate == null || inputDate == undefined)
            return '';
        
        var d = new Date(inputDate);
        return [this.pad(d.getDate()), this.pad(d.getMonth()+1), d.getFullYear()].join('/');        
    },
    pad: function(inputStr) {        
        return (inputStr < 10) ? '0' + inputStr : inputStr;
    },
    getSignal : function (check, checkOn) {
        
        if(checkOn == "P2P_Eligibility"){
            if(check == "Fail")
                return 'Fail';
            
            if(check == "Pass")
                return 'Pass';
            
            return '';
        } else {
            if(check == "Red")
                return 'Fail';
            
            if(check == "Green")
                return 'Pass';
            
            if(check == "White")
                return 'Unknown';
            
            if(check == "None")
                return '';
            else 
                return 'System Error';
        }
    },
    showSpinner : function(component, event){
        console.log('show spinner');
        var spinner = component.find("spinner");
        console.log(spinner);
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner : function(component, event){
        console.log('hide spinner');
        var spinner = component.find("spinner");
        console.log(spinner);
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
})