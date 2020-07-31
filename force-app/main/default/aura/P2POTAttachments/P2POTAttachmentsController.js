({
	initialize : function(component, event, helper) {
        console.log("start in controller :: before helper.list :: "+component.get("v.parent"))
		helper.list(component, event, component.get("v.parent"));
        helper.checkCaseStatus(component, event, component.get("v.parent"));
	},
    
    confirmDeleteAttachment : function (component, event, helper){
        var attachmentId = event.getParam("recordId");
        console.log('Delete attchments Confirmation for id >>' + attachmentId);
        helper.deleteAttachmentHelper(component, event, attachmentId)
        
    },
    
    deleteAttachment : function (component, event, helper){
        var recId = event.currentTarget.getAttribute("data-recordId");
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "Please ensure that required files are part of the application by uploading files from the previous application process steps. Are you sure you want to delete this attachment?",
                "recordId" : recId,
                "confirmType": "DeleteAttchment"
            },
            function(newComponent, status, errorMessage){
                console.log(status);
                if (status === "SUCCESS") {                    
                    component.set("v.body", newComponent);                    
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }                
            }
        );
    },
    
    viewAttachment : function (component, event, helper){  
        console.log("start in controller :: before helper.list ::>>!!"+component.get("v.parent"));
        var attachmentId = event.currentTarget.getAttribute("data-recordId");
        
        var locationURL = window.location;
       
        console.log('location url'+locationURL);
        
        //this is used to differentiate between industry and taxi
        var portalName = locationURL.pathname.substring(1,20);
        var portalName = portalName.substring(0,portalName.indexOf('/'));
        
        console.log('portal name >>' + portalName);
       
        //created a base url
        if(portalName != 'lightning')
        	var attchmentURL = locationURL.protocol + '//' + locationURL.host + '/' + portalName;
        else
            var attchmentURL = locationURL.protocol + '//' + locationURL.host;
        console.log("base url>> "+attchmentURL);
        
        //on this url will be able to view attachment
        var url = attchmentURL + "/servlet/servlet.FileDownload?file=" + attachmentId;
        window.open(url, '_blank');
    },
})